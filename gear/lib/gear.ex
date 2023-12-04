defmodule Gear do
  @moduledoc """
  Documentation for `Gear`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    m = input(filename)
    sym = Map.get(m, :sym)
    sym
    |> Enum.flat_map(fn p -> adjacent(m, p) end)
    |> Enum.map(fn p -> get_num(m, p) end)
    |> Enum.sum()
  end

  def adjacent(m, {x, y}) do
    [
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1},
    ]
    |> Enum.map(fn p -> {p, Map.has_key?(m, p)} end)
    |> fuse()
  end

  def fuse([a, b, c, d, e, f, g, h]) do
    fuse([a, b, c]) ++ fuse(d) ++ fuse(e) ++ fuse([f, g, h])
  end

  def fuse({a, true}), do: [a]
  def fuse({_, false}), do: []
  def fuse([{a, true}, {_, false}, {_, false}]), do: [a]
  def fuse([{a, true}, {_, true}, {_, _}]), do: [a]
  def fuse([{a, true}, {_, true}, {_, true}]), do: [a]
  def fuse([{_, false}, {b, true}, {_, true}]), do: [b]
  def fuse([{_, false}, {b, true}, {_, false}]), do: [b]
  def fuse([{_, false}, {_, false}, {c, true}]), do: [c]
  def fuse([{a, true}, {_, false}, {c, true}]), do: [a, c]
  def fuse(_), do: []

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    m = input(filename)

    m
    |> Map.get(:gear)
    |> Enum.map(fn p -> adjacent(m, p) end)
    |> Enum.filter(fn xs when length(xs) == 2 -> true; _ -> false end)
    |> Enum.map(fn xs ->
      xs |> Enum.map(fn p -> get_num(m, p) end) |> Enum.product()
    end)
    |> Enum.sum()
  end

  @doc """
  input function
  """
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n")
    |> Enum.reduce(
      {0, 0, %{}},
      fn line, {_x, y, m} ->
        new_m =
          line
          |> String.to_charlist()
          |> Enum.reduce(
            {0, y, m},
            fn ch, {x, y, m} ->
              new_m =
                case conv(ch) do
                  :sym ->
                    Map.update(m, :sym, [{x, y}], fn ls -> [{x, y} | ls] end)
                  :gear ->
                    m
                    |> Map.update(:sym, [{x, y}], fn ls -> [{x, y} | ls] end)
                    |> Map.update(:gear, [{x, y}], fn ls -> [{x, y} | ls] end)
                  :dot ->
                    m

                  n ->
                    Map.put(m, {x, y}, n)
                end

              {x + 1, y, new_m}
            end
          )
          |> then(fn {_x, _y, m} -> m end)

        {0, y + 1, new_m}
      end
    )
    |> then(fn {_x, _y, m} -> m end)
  end

  def conv(?.), do: :dot
  def conv(?*), do: :gear
  def conv(ch) when ch >= 48 and ch <= 57, do: ch - 48
  def conv(_), do: :sym

  @spec get_num(map(), {non_neg_integer(), non_neg_integer()}) :: non_neg_integer()
  def get_num(m, {x, y}) do
    left =
      Enum.reduce_while(
        x..0,
        [],
        fn x, acc ->
          case Map.get(m, {x, y}) do
            nil -> {:halt, acc}
            k -> {:cont, [k | acc]}
          end
        end
      )

    right =
      Enum.reduce_while(
        (x + 1)..140,
        [],
        fn x, acc ->
          case Map.get(m, {x, y}) do
            nil -> {:halt, acc}
            k -> {:cont, [k | acc]}
          end
        end
      )
      |> Enum.reverse()

    Enum.join(left ++ right, "")
    |> String.to_integer()
  end
end
