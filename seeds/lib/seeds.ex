defmodule Seeds do
  @moduledoc """
  Documentation for `Seeds`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    {seeds, maps} = input(filename)

    seeds
    |> Enum.map(fn seed ->
      Enum.reduce(maps, seed, fn m, acc -> mapping(acc, m) end)
    end)
    |> Enum.min()
  end

  def mapping(seed, {_name, []}), do: seed
  def mapping(seed, {_name, [{s, _d, _len} | _]}) when seed < s, do: seed
  def mapping(seed, {_name, [{s, d, len} | _]}) when seed >= s and seed < s + len do
    off = seed - s
    d + off
  end
  def mapping(seed, {name, [_r | rs]}), do: mapping(seed, {name, rs})

  def part2(:prod), do: part2("input.txt")
  def part2(:example), do: part2("example.txt")

  def part2(filename) do
    {seeds, maps} = input(filename)

    seeds
    |> calc_ranges()
    |> Enum.reduce(
      nil,
      fn {start_seed, max_seed}, min ->
        part2_iter(start_seed, max_seed, min, maps)
        |> IO.inspect()
    end)
  end

  def part2_iter(max_seed, max_seed, min, _maps), do: min
  def part2_iter(seed, max_seed, min, maps) do
    location = Enum.reduce(maps, seed, fn m, acc -> mapping(acc, m) end)
    new_min = min_loc(location, min)
    part2_iter(seed + 1, max_seed, new_min, maps)
  end

  defp min_loc(m, nil), do: m
  defp min_loc(a, b) when a < b, do: a
  defp min_loc(_a, b), do: b

  def calc_ranges(seeds) do
    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [s, l] -> {s, s + l - 1} end)
    |> Enum.sort(fn {s1, _}, {s2, _} -> s1 < s2 end)
  end

  @doc """
  input function
  """
  def input(filename) do
    [seeds | maps] =
      filename
      |> File.read!()
      |> String.split("\n\n")

    [_ | seeds] = String.split(seeds, " ", trim: true)

    maps =
      maps
      |> Enum.map(fn m ->
        [name | ranges] = String.split(m, "\n")
        {parse_name(name), parse_ranges(ranges)}
      end)

    {as_numbers(seeds), maps}
  end

  def parse_name(name) do
    [x, y] =
      name
      |> String.replace(" map:", "")
      |> String.split("-to-")
      |> Enum.map(&String.to_atom/1)

    {x, y}
  end

  def parse_ranges(ranges) do
    ranges
    |> Enum.map(&String.split/1)
    |> Enum.map(&as_numbers/1)
    |> Enum.map(fn [dst_rng_start, src_rng_start, len] ->
      {src_rng_start, dst_rng_start, len}
    end)
    |> Enum.sort_by(fn {s, _d, _len} -> s end)
  end

  defp as_numbers(xs) when is_list(xs) do
    Enum.map(xs, &as_number/1)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
