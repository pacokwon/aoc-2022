defmodule Solution1 do
  defp split_line(line) do
    line
    |> String.split(",")
    |> Enum.map(&(&1 |> String.split("-") |> Enum.map(fn x -> String.to_integer(x) end)))
  end

  defp fully_contains([[a_start, a_end], [b_start, b_end]]) do
    a = MapSet.new(a_start..a_end)
    b = MapSet.new(b_start..b_end)

    intersection = MapSet.intersection(a, b)
    intersection_size = MapSet.size(intersection)
    intersection_size == MapSet.size(a) or intersection_size == MapSet.size(b)
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    IO.read(file, :all)
    |> String.split("\n")
    |> Stream.drop(-1)
    |> Stream.map(&split_line/1)
    |> Stream.map(&fully_contains/1)
    |> Stream.filter(&Function.identity/1)
    |> Enum.to_list()
    |> then(&length/1)
    |> IO.inspect()
  end
end

defmodule Solution2 do
  defp split_line(line) do
    line
    |> String.split(",")
    |> Enum.map(&(&1 |> String.split("-") |> Enum.map(fn x -> String.to_integer(x) end)))
  end

  defp overlaps([[a_start, a_end], [b_start, b_end]]) do
    a = MapSet.new(a_start..a_end)
    b = MapSet.new(b_start..b_end)

    intersection = MapSet.intersection(a, b)
    intersection_size = MapSet.size(intersection)
    intersection_size > 0
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    IO.read(file, :all)
    |> String.split("\n")
    |> Stream.drop(-1)
    |> Stream.map(&split_line/1)
    |> Stream.map(&overlaps/1)
    |> Stream.filter(&Function.identity/1)
    |> Enum.to_list()
    |> then(&length/1)
    |> IO.inspect()
  end
end

Solution2.run("input.txt")
