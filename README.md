# AdventOfCode

This is a repo of my [Advent of Code](https://adventofcode.com) solutions
written in elixir.

# Project layout

```
├── input ----This folder holds your inputs)
│   └── {year}
│       └── {day}.txt
├── lib
│   ├── {year} ----(This is where your solutions are)
│   │   └── {day}.ex
│   ├── advent_of_code.ex ----(Main module)
│   ├── mix ----(Mix tasks)
│   │   └── tasks
│   │       ├── exec.ex
│   │       └── gen.ex
│   └── template.eex ----(Template used to generate)
├── mix.exs
└── test
    ├── advent_of_code_test.exs
    └── test_helper.exs
```

In general, you should only ever need to touch files generated in `input/` and `lib/{year}`. You're welcome to change `lib/template.eex` to meet your needs. You may also add doctests in `test/advent_of_code_test.exs`.

# Setup

1. Install [elixir](https://elixir-lang.org/install.html) and its dependencies.

2. Clone this repo

# Usage

## Generate a solution file

This command generates a file based on the template located at `lib/template.eex` and an empty input file that's put at `input/{year}/{day}.txt`.

If you have an environment variable `ADVENT_OF_CODE_SESSION` with a value set to your session cookie on adventofcode.com, it will attempt to fetch your personalized input from there. Otherwise it will just create an empty file.

Examples:

```sh
mix gen --year 2015 --day 3
mix gen -y 2015 -d 3         # short form
mix gen -d 10                # assume year
mix gen                      # assume year and day 1
mix gen -y 2020              # assume day 1
mix gen 2020 20              # position arguments work as well
mix gen 15                   # assume current year
```

Note that for any file this command generates, it will not overwrite any existing files.

You can modify the template to do whatever you'd like, but the module name must match a specific format. Here's a minimal template if you'd like to use that instead:

```elixir
defmodule Y<%= year %>.D<%= day %> do
  def part_1(input) do
    input
  end

  def part_2(input) do
    input
  end
end
```

You can still use doctests, but you won't have the `input()` helper function or behaviour compile-time checks.

Here's an alternate version without the top-level import and `solution` macro but you still get the `input()` helper function as well as behavior compile-time checks.

```elixir
defmodule Y<%= year %>.D<%= day %> do
  use AdventOfCode, year: <%= year %>, day: <%= day %>

  @doc ~S"""
  ## Examples
      iex> input() |> part_1()
      input()
  """
  def part_1(input) do
    input
  end

  @doc ~S"""
  ## Examples
      iex> input() |> part_2()
      input()
  """
  def part_2(input) do
    input
  end
end
```

## Run a solution file

A mix task to run your Advent of Code solution based on the input you've put in at input/{year}/{day}.txt

Examples:

```sh
mix exec --year 2021 --day 25 --part 1
mix exec -y 2021 -d 25 -p 1
mix exec -y 2019 -d 5                   # assume part 1
mix exec -y 2015 -p 2                   # assume day 1
mix exec -d 20                          # assume current year
mix exec -y 2015 -d 1 -p 2 --input "()" # pass in custom input
mix exec 2015 1 2 "()"                  # positional arguments work as well
mix exec 7 "())("                       # if first number isn't 2015 or greater, it will assume current year
```

Some aliases were put in places in `mix.ex` but feel free to modify those to your liking.

## Doctests

You may find it useful to write doctests for the examples that each puzzle gives you. Example doctests are in the generated solution code. If you would like to run them, you need to add a line to the `test/advent_of_code_test.exs` file for each "day":

```elixir
defmodule AdventOfCodeTest do
  use ExUnit.Case
  import AdventOfCode.TestHelper

  advent_test 2015, 1
end
```

Now you can run to run those doctests:

```sh
mix test
```

If you'd like to skip a test, just add `, :skip` or `, skip: true` to the end
of the test:

```elixir
advent_test, 2015, 1, :skip
advent_test, 2015, 2, skip: true
```
