defmodule CubeConundrum do
  @moduledoc """
  Documentation for `CubeConundrum`.
  """

  @part1_bag {12, 13, 14}

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    filename
    |> input()
    |> max_cube()
    |> possible(@part1_bag)
    |> Enum.sum()
  end

  def possible(games, {red, green, blue}) do
    games
    |> Enum.filter(fn
      {_id, {r, g, b}} when r <= red and g <= green and b <= blue -> true
      _ -> false
    end)
    |> Enum.map(fn {id, _sets} -> id end)
  end

  def max_cube(games) do
    games
    |> Enum.map(fn %{id: id, sets: sets} ->
      max_set =
        sets
        |> Enum.reduce(
          {0, 0, 0},
          fn set, {red, green, blue} ->
            r = Map.get(set, :red, 0)
            g = Map.get(set, :green, 0)
            b = Map.get(set, :blue, 0)
            {:erlang.max(r, red), :erlang.max(g, green), :erlang.max(b, blue)}
          end
        )

      {id, max_set}
    end)
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    filename
    |> input()
    |> max_cube()
    |> power()
    |> Enum.sum()
  end

  def power(games) do
    games
    |> Enum.map(fn {_id, {r, g, b}} -> r * g * b end)
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      ["Game " <> id, sets] = String.split(line, ": ", trim: true)

      sets_list =
        sets
        |> String.split("; ", trim: true)
        |> Enum.map(fn set ->
          set
          |> String.split(", ", trim: true)
          |> Enum.reduce(
            %{},
            fn set_tks, acc ->
              [ncub_str, color] = String.split(set_tks, " ")
              Map.put(acc, String.to_atom(color), as_number(ncub_str))
            end
          )
        end)

      %{id: as_number(id), sets: sets_list}
    end)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
