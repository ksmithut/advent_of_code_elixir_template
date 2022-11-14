defmodule AdventOfCode do
  @moduledoc """
  A helper module to run your advent of code solutions.

  Solution usage:

  You can use this module to pull in your puzzle's input in your doctests

      @doc ~S\"\"\"
          iex> AdventOfCode.input(2015, 7) |> part_1()
          23
      \"\"\"

  You can also "use" it get an automatic `input/0` function that will get your puzzle's input

      use AdventventOfCode, year: 2015, day: 7

      @doc ~S\"\"\"
          iex> input() |> part_1()
          23
      \"\"\"

  "use"ing it also enforces via compile-time warnings that you have implemented both part_1 and part_2 functions
  """

  @callback part_1(String.t()) :: any()
  @callback part_2(String.t()) :: any()

  @spec solution(integer(), integer(), [{:do, any}, ...]) :: any()
  defmacro solution(year, day, do: body) do
    quote do
      defmodule unquote(module_name(year, day)) do
        use unquote(__MODULE__), year: unquote(year), day: unquote(day)

        unquote(body)
      end
    end
  end

  defmacro __using__(opts) do
    year = Keyword.fetch!(opts, :year)
    day = Keyword.fetch!(opts, :day)

    quote do
      @behaviour unquote(__MODULE__)
      def input, do: unquote(__MODULE__).input(unquote(year), unquote(day))
      defoverridable input: 0
    end
  end

  def module_name(year, day) do
    Module.concat(String.to_atom("Y#{year}"), String.to_atom("D#{pad_day(day)}"))
  end

  @spec input(integer(), integer()) :: binary()
  def input(year, day), do: input_path(year, day) |> File.read!()

  def run_part(year, day, part, input) do
    module = module_name(year, day)
    input = if input == nil, do: input(year, day), else: input

    case part do
      1 -> {:ok, module.part_1(input)}
      2 -> {:ok, module.part_2(input)}
      _ -> {:error, "no such part_#{part}"}
    end
  end

  @template EEx.compile_file(Path.join(["lib", "template.eex"]))
  @session_env "ADVENT_OF_CODE_SESSION"

  @spec generate(integer, integer) :: :ok
  def generate(year, day) do
    with session <- System.get_env(@session_env),
         {:ok, input} <- fetch_input(year, day, session),
         {code, _} = Code.eval_quoted(@template, year: year, day: day) do
      input_path(year, day) |> create_file(input)
      code_path(year, day) |> create_file(code)
    else
      {:error, error} -> IO.warn(error, [])
    end
  end

  defp pad_day(day), do: day |> to_string() |> String.pad_leading(2, "0")
  defp input_path(year, day), do: Path.join(["input", "#{year}", "#{pad_day(day)}.txt"])
  defp code_path(year, day), do: Path.join(["lib", "#{year}", "#{pad_day(day)}.ex"])

  defp fetch_input(_, _, nil), do: ""
  defp fetch_input(_, _, ""), do: ""

  defp fetch_input(year, day, session) do
    Application.ensure_all_started(:inets)
    Application.ensure_all_started(:ssl)
    url = "https://adventofcode.com/#{year}/day/#{day}/input"
    headers = [{'Cookie', "session=#{session}"}]
    options = [ssl: [verify: :verify_none]]

    case :httpc.request(:get, {url, headers}, options, []) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        {:ok, body}

      {:ok, {{_, 404, _}, _headers, _body}} ->
        {:error, "Input not found (yet?)"}

      {:ok, {{_, 400, _}, _headers, _body}} ->
        {:error, "Invalid session"}

      error ->
        IO.inspect(error)
        {:error, "Invalid adventofcode.com session"}
    end
  end

  defp create_file(path, contents) do
    :ok = File.mkdir_p!(Path.dirname(path))

    case File.exists?(path) do
      true ->
        IO.warn("File already exists at #{path}", [])

      _ ->
        :ok = File.write!(path, contents)
        IO.puts("Generated #{path}")
    end
  end

  defmodule TestHelper do
    import ExUnit.DocTest

    defmacro advent_test(year, day, opts \\ []) do
      skip = opts == :skip or opts[:skip] == true

      unless skip do
        quote do
          doctest AdventOfCode.module_name(unquote(year), unquote(day)), import: true
        end
      end
    end
  end
end
