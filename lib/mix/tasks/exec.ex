defmodule Mix.Tasks.Exec do
  @moduledoc """
  A mix task to run your Advent of Code solution based on the input you've put in at input/{year}/{day}.txt

  Examples

      mix exec --year 2021 --day 25 --part 1
      mix exec -y 2021 -d 25 -p 1
      mix exec -y 2019 -d 5                   # assume part 1
      mix exec -y 2015 -p 2                   # assume day 1
      mix exec -d 20                          # assume current year
      mix exec -y 2015 -d 1 -p 2 --input "()" # pass in custom input
      mix exec 2015 1 2 "()"                  # positional arguments work as well
      mix exec 7 "())("                       # if first number isn't 2015 or greater, it will assume current year
  """
  @shortdoc "Run the given Advent of Code solution"
  use Mix.Task

  def run(args) do
    {year, day, part, input} = parse_args!(args)

    case AdventOfCode.run_part(year, day, part, input) do
      {:ok, value} -> if is_binary(value), do: IO.puts(value), else: IO.inspect(value)
      {:error, reason} -> IO.warn(reason)
    end
  end

  def current_year() do
    %{year: year, month: month} = Date.utc_today()

    case month do
      12 -> year
      11 -> year
      _ -> year - 1
    end
  end

  def parse_args!(args) do
    switches = [year: :integer, day: :integer, part: :integer, input: :string]
    aliases = [y: :year, d: :day, p: :part, i: :input]

    opts =
      case OptionParser.parse(args, aliases: aliases, strict: switches) do
        {opts, [], []} -> opts
        {opts, args, []} -> parse_positional_args(opts, args)
        {_, [], any} -> Mix.raise("Invalid option(s): #{inspect(any)}")
        {_, any, _} -> Mix.raise("Unexpected argument(s): #{inspect(any)}")
      end

    input = if opts[:input] == nil, do: nil, else: String.replace(opts[:input], "\\n", "\n")

    {opts[:year] || current_year(), opts[:day] || 1, opts[:part] || 1, input}
  end

  defp parse_positional_args(opts, args) do
    Enum.reduce(args, opts, fn arg, opts ->
      parse_year(opts, arg)
    end)
  end

  defp parse_year(opts, arg) do
    with nil <- opts[:year],
         {num, _} <- Integer.parse(arg),
         # TODO:: come back towards the end of this millenium to bump this number up
         true <- num in 2015..3000 do
      Keyword.put(opts, :year, num)
    else
      _ -> parse_day(opts, arg)
    end
  end

  defp parse_day(opts, arg) do
    with nil <- opts[:day],
         {num, _} <- Integer.parse(arg),
         true <- num in 1..25 do
      Keyword.put(opts, :day, num)
    else
      _ -> parse_part(opts, arg)
    end
  end

  defp parse_part(opts, arg) do
    with nil <- opts[:part],
         {num, _} <- Integer.parse(arg),
         true <- num in 1..2 do
      Keyword.put(opts, :part, num)
    else
      _ -> parse_input(opts, arg)
    end
  end

  defp parse_input(opts, arg) do
    with nil <- opts[:input] do
      Keyword.put(opts, :input, arg)
    else
      _ -> opts
    end
  end
end
