defmodule Camel do
  @moduledoc """
  Documentation for `Camel`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    filename
    |> input()
    |> Enum.sort(fn {h1, _b1}, {h2, _b2} ->
      compare_hand(h1, h2, &hand_type/1, &rank/1)
    end)
    |> Enum.reduce(
      {1, 0},
      fn {_h, b}, {r, acc} -> {r + 1, acc + b * r} end
    )
    |> then(fn {_, r} -> r end)
  end

  def compare_hand(h1, h2, hand_type_fn, rank_fn) do
    case {hand_type_fn.(h1), hand_type_fn.(h2)} do
      {k, k} -> compare_cards(h1, h2, rank_fn)
      {:five_of_kind, _} -> false
      {_, :five_of_kind} -> true
      {:four_of_kind, _} -> false
      {_, :four_of_kind} -> true
      {:full_house, _} -> false
      {_, :full_house} -> true
      {:three_of_kind, _} -> false
      {_, :three_of_kind} -> true
      {:two_pair, _} -> false
      {_, :two_pair} -> true
      {:one_pair, :high_card} -> false
      {:high_card, :one_pair} -> true
    end
  end

  def compare_cards(h1, h2, rank_fn) do
    Enum.zip(h1, h2)
    |> Enum.reduce_while(
      nil,
      fn
        {a, a}, acc ->
          {:cont, acc}

        {a, b}, _acc ->
          {:halt, rank_fn.(a) < rank_fn.(b)}
      end
    )
  end

  defp rank(:A), do: 14
  defp rank(:K), do: 13
  defp rank(:Q), do: 12
  defp rank(:J), do: 11
  defp rank(:T), do: 10
  defp rank(c), do: c

  defp rank_p2(:J), do: 1
  defp rank_p2(c), do: rank(c)

  defp hand_type(h) do
    f =
      h
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort(:desc)

    case f do
      [5] -> :five_of_kind
      [4, 1] -> :four_of_kind
      [3, 2] -> :full_house
      [3, 1, 1] -> :three_of_kind
      [2, 2, 1] -> :two_pair
      [2, 1, 1, 1] -> :one_pair
      [1, 1, 1, 1, 1] -> :high_card
    end
  end

  defp hand_type_p2([x, x, x, x, x]), do: :five_of_kind

  defp hand_type_p2(h) do
    f = Enum.frequencies(h)
    jf = Map.get(f, :J, 0)
    [h | new_fs] = f |> Map.delete(:J) |> Map.values() |> Enum.sort(:desc)

    case [h + jf | new_fs] do
      [5] -> :five_of_kind
      [4, 1] -> :four_of_kind
      [3, 2] -> :full_house
      [3, 1, 1] -> :three_of_kind
      [2, 2, 1] -> :two_pair
      [2, 1, 1, 1] -> :one_pair
      [1, 1, 1, 1, 1] -> :high_card
    end
  end

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    filename
    |> input()
    |> Enum.sort(fn {h1, _b1}, {h2, _b2} ->
      compare_hand(h1, h2, &hand_type_p2/1, &rank_p2/1)
    end)
    |> Enum.reduce(
      {1, 0},
      fn {_h, b}, {r, acc} -> {r + 1, acc + b * r} end
    )
    |> then(fn {_, r} -> r end)
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [hand, bid_txt] = String.split(line, " ")
      {parse_hand(hand), as_number(bid_txt)}
    end)
  end

  defp parse_hand(hand) do
    hand
    |> String.to_charlist()
    |> Enum.map(fn
      ch when ch >= 48 and ch <= 57 ->
        ch - 48

      ch ->
        List.to_atom([ch])
    end)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
