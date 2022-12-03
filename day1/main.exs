defmodule Solution1 do
  def run(filename) do
      file = case File.open(filename) do
        { :ok, file } -> file
        _ -> raise RuntimeError
      end

      lines = IO.read(file, :all)
            |> String.split("\n")

      { answer, _ } = Enum.reduce(lines, { [], 0 }, fn
        "", { result, sum } -> { [sum | result], 0 }
        line, { result, sum } -> { result, sum + String.to_integer line }
      end)

      answer
      |> Enum.max
      |> IO.inspect
  end
end

defmodule Solution2 do
  def run(filename) do
      file = case File.open(filename) do
        { :ok, file } -> file
        _ -> raise RuntimeError
      end

      lines = IO.read(file, :all)
            |> String.split("\n")

      { calories, _ } = Enum.reduce(lines, { [], 0 }, fn
        "", { result, sum } -> { [sum | result], 0 }
        line, { result, sum } -> { result, sum + String.to_integer line }
      end)

      calories
      |> Enum.sort(:desc)
      |> Enum.take(3)
      |> Enum.sum
      |> IO.inspect
  end
end

Solution2.run("input.txt")
