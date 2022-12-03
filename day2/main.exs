defmodule Solution1 do
  defp compute_win(cpu, me) do
    case cpu do
      "A" ->
        case me do
          "X" -> 3
          "Y" -> 6
          "Z" -> 0
        end
      "B" ->
        case me do
          "X" -> 0
          "Y" -> 3
          "Z" -> 6
        end
      "C" ->
        case me do
          "X" -> 6
          "Y" -> 0
          "Z" -> 3
        end
    end
  end

  defp compute_point([cpu, me | _]) do
    compute_win(cpu, me) + case me do "X" -> 1; "Y" -> 2; "Z" -> 3 end
  end

  def run(filename) do
      file = case File.open(filename) do
        { :ok, file } -> file
        _ -> raise RuntimeError
      end

      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.map(&String.split/1)
      |> Enum.drop(-1)
      |> Enum.map(&compute_point/1)
      |> Enum.sum
      |> IO.inspect
  end
end

defmodule Solution2 do
  defp compute_response(cpu, instruction) do
    # A -> rock, B -> paper, C -> scissors
    # (instruction) X -> lose, Y -> draw, Z -> win
    # X -> rock, Y -> paper, Z -> scissors
    case cpu do
      "A" ->
        case instruction do
          "X" -> { 0, "Z" }
          "Y" -> { 3, "X" }
          "Z" -> { 6, "Y" }
        end
      "B" ->
        case instruction do
          "X" -> { 0, "X" }
          "Y" -> { 3, "Y" }
          "Z" -> { 6, "Z" }
        end
      "C" ->
        case instruction do
          "X" -> { 0, "Y" }
          "Y" -> { 3, "Z" }
          "Z" -> { 6, "X" }
        end
    end
  end

  defp compute_point([cpu, me | _]) do
    { point, response } = compute_response(cpu, me)
    point + case response do "X" -> 1; "Y" -> 2; "Z" -> 3 end
  end

  def run(filename) do
      file = case File.open(filename) do
        { :ok, file } -> file
        _ -> raise RuntimeError
      end

      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.map(&String.split/1)
      |> Enum.drop(-1)
      |> Enum.map(&compute_point/1)
      |> Enum.sum
      |> IO.inspect
  end
end

Solution2.run("input.txt")
