defmodule Day6.Solution1 do
  defp has_duplicate({lst, _}) do
    size = lst |> MapSet.new() |> MapSet.size()
    size != length(lst)
  end

  def run(filename) do
      file = case File.open(filename) do
        { :ok, file } -> file
        _ -> raise RuntimeError
      end

      chunk_size = 4

      lines = IO.read(file, :all)
            |> String.split("\n")
            |> Enum.at(0)
            |> String.to_charlist()
            |> Stream.chunk_every(chunk_size, 1, :discard)
            |> Stream.with_index()
            |> Stream.drop_while(&has_duplicate/1)
            |> Stream.take(1)
            |> Enum.at(0)
            |> elem(1)
            |> then(&(&1 + chunk_size))

      IO.inspect lines
  end
end

defmodule Day6.Solution2 do
  defp has_duplicate({lst, _}) do
    size = lst |> MapSet.new() |> MapSet.size()
    size != length(lst)
  end

  def run(filename) do
      file = case File.open(filename) do
        { :ok, file } -> file
        _ -> raise RuntimeError
      end

      chunk_size = 14

      lines = IO.read(file, :all)
            |> String.split("\n")
            |> Enum.at(0)
            |> String.to_charlist()
            |> Stream.chunk_every(chunk_size, 1, :discard)
            |> Stream.with_index()
            |> Stream.drop_while(&has_duplicate/1)
            |> Stream.take(1)
            |> Enum.at(0)
            |> elem(1)
            |> then(&(&1 + chunk_size))

      IO.inspect lines
  end
end

Day6.Solution2.run("input.txt")
