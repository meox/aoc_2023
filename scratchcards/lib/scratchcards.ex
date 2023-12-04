defmodule Scratchcards do
  @moduledoc """
  Documentation for `Scratchcards`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    filename
    |> input()
    |> Enum.map(fn {_id, wins, ns} ->
      matches =
        ns
        |> Enum.filter(fn x -> MapSet.member?(wins, x) end)
        |> Enum.count()

      point(matches)
    end)
    |> Enum.sum()
  end

  defp point(0), do: 0
  defp point(1), do: 1
  defp point(n), do: 2 * point(n - 1)

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    m =
      filename
      |> input()
      |> Map.new(fn {id, wins, ns} -> {id, {wins, ns}} end)

    keys = Map.keys(m)
    max_cards = Enum.max(keys)
    init_state = Map.new(keys, fn id -> {id, 1} end)

    m
    |> play_part2(1, max_cards, init_state)
    |> Map.values()
    |> Enum.sum()
  end

  def play_part2(_m, max_cards, max_cards, state), do: state

  def play_part2(m, game, max_cards, state) do
    times = Map.get(state, game)
    matches = calc_matches(m, game)
    copied_gards = copies(game, matches, max_cards)

    new_state =
      copied_gards
      |> Enum.reduce(
        state,
        fn c, acc ->
          Map.update(acc, c, times, fn e -> e + times end)
        end
      )

    play_part2(m, game + 1, max_cards, new_state)
  end

  def copies(_game, 0, _max_cards), do: []

  def copies(game, m, max_cards) when game + m <= max_cards,
    do: [game + m | copies(game, m - 1, max_cards)]

  def copies(game, m, max_cards), do: copies(game, m - 1, max_cards)

  defp calc_matches(m, game) do
    {wins, ns} = Map.get(m, game, {MapSet.new(), []})

    ns
    |> Enum.filter(fn x -> MapSet.member?(wins, x) end)
    |> Enum.count()
  end

  @doc """
  input function
  """
  def input(filename) do
    # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      ["Card " <> id, ns] = String.split(line, ": ", trim: true)
      [ns_l, ns_r] = String.split(ns, " | ")
      ns_l = String.split(ns_l, ~r/\s+/, trim: true)
      ns_r = String.split(ns_r, ~r/\s+/, trim: true)
      {as_number(id), MapSet.new(as_numbers(ns_l)), as_numbers(ns_r)}
    end)
  end

  defp as_numbers(xs) when is_list(xs) do
    Enum.map(xs, &as_number/1)
  end

  defp as_number(s) do
    {n, ""} = s |> String.trim() |> Integer.parse()
    n
  end
end
