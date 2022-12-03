defmodule Solution1 do
  defp priority(c) when ?a <= c and c <= ?z do
    c - ?a + 1
  end

  defp priority(c) when ?A <= c and c <= ?Z do
    c - ?A + 27
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
    |> Stream.map(&String.to_charlist/1)
    |> Stream.map(&Enum.split(&1, floor(length(&1) / 2)))
    |> Stream.map(fn {a, b} ->
      MapSet.new(a) |> MapSet.intersection(MapSet.new(b)) |> MapSet.to_list() |> hd |> priority
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end

defmodule Solution2 do
  defp priority(c) when ?a <= c and c <= ?z do
    c - ?a + 1
  end

  defp priority(c) when ?A <= c and c <= ?Z do
    c - ?A + 27
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
    |> Stream.map(&String.to_charlist/1)
    |> Stream.map(&MapSet.new/1)
    |> Stream.chunk_every(3)
    |> Stream.map(fn [a, b, c] ->
      a |> MapSet.intersection(b) |> MapSet.intersection(c) |> MapSet.to_list() |> hd |> priority
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end

Solution2.run("sample.txt")
