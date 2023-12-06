defmodule WaitForIt do
  @moduledoc """
  Documentation for `WaitForIt`.
  """

  def part1(:prod), do: part1("input.txt")
  def part1(:example), do: part1("example.txt")

  def part1(filename) do
    filename
    |> input()
    |> Enum.map(&dist_win/1)
    |> Enum.product()
  end

  def dist_win({max_t, record_dist}) do
    dist_win(max_t - 1, max_t, record_dist, 0, false)
  end

  def dist_win(0, _max_t, _record_dist, c, _new_record_found), do: c

  def dist_win(f, max_t, record_dist, c, new_record_found) do
    d = f * (max_t - f)

    if d > record_dist do
      dist_win(f - 1, max_t, record_dist, c + 1, true)
    else
      if new_record_found do
        c
      else
        dist_win(f - 1, max_t, record_dist, c, new_record_found)
      end
    end
  end

  def part2(:prod), do: part2({34_908_986, 204_171_312_101_780})
  def part2(:example), do: part2({71530, 940_200})

  def part2({max_t, record_dist}) do
    dist_win({max_t, record_dist})
  end

  @doc """
  input function
  """
  def input(filename) do
    [a, b] =
      filename
      |> File.read!()
      |> String.split("\n")

    [_ | ts] = a |> String.split(" ", trim: true)
    [_ | ds] = b |> String.split(" ", trim: true)

    Enum.zip(as_numbers(ts), as_numbers(ds))
  end

  defp as_numbers(xs) when is_list(xs) do
    Enum.map(xs, &as_number/1)
  end

  defp as_number(s) do
    {n, ""} = Integer.parse(s)
    n
  end
end
