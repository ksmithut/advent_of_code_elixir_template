defmodule Mix.Tasks.Gen do
  @moduledoc """
  This command generates a file based on the template located at `lib/template.eex` and an empty input file that's put at `input/{year}/{day}.txt`.

  If you have an environment variable `ADVENT_OF_CODE_SESSION` with a value set to your session cookie on adventofcode.com, it will attempt to fetch your personalized input from there. Otherwise it will just create an empty file.

  Examples:

      mix gen --year 2015 --day 3
      mix gen -y 2015 -d 3         # short form
      mix gen -d 10                # assume year
      mix gen                      # assume year and day 1
      mix gen -y 2020              # assume day 1
      mix gen 2020 20              # position arguments work as well
      mix gen 15                   # assume current year
  """
  @shortdoc "Generate a new Advent of Code solution file"
  use Mix.Task
  import Mix.Tasks.Exec, only: [parse_args!: 1]

  def run(args) do
    {year, day, _, _} = parse_args!(args)
    AdventOfCode.generate(year, day) |> post_generate()
  end

  defp post_generate({:ok, input_path, code_path} = result) do
    if System.get_env("VSCODE_INJECTION") do
      System.cmd("code", [code_path, input_path])
    end

    result
  end

  defp post_generate(result), do: result
end
