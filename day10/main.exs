defmodule Util do
  defp parse_line("addx " <> num) do
    {:addx, String.to_integer(num)}
  end

  defp parse_line("noop") do
    {:noop}
  end

  def parse(lines) do
    lines |> Enum.map(&parse_line/1)
  end

  def log(obj) do
    IO.inspect(obj)
    obj
  end
end

defmodule Day10.Solution1 do
  @cycle 40
  @limit 220

  def run_inst({:addx, count}, {x, cycles, acc, next}) do
    new_x = x + count
    new_cycles = cycles + 2
    cond do
      new_cycles > next and next == @limit -> {:halt, [x * next | acc]}
      new_cycles == next and next == @limit -> {:halt, [x * next | acc]}
      new_cycles > next -> {:cont, {new_x, new_cycles, [x * next | acc], next + @cycle}}
      new_cycles == next -> {:cont, {new_x, new_cycles, [new_x * next | acc], next + @cycle}}
      true -> {:cont, {new_x, new_cycles, acc, next}}
    end
  end

  def run_inst({:noop}, {x, cycles, acc, next}) do
    cycles = cycles + 1
    cond do
      cycles >= next and next == @limit ->
        {:halt, [x * next | acc]}

      cycles >= next ->
        {:cont, {x, cycles, [x * next | acc], next + @cycle}}

      true ->
        {:cont, {x, cycles, acc, next}}
    end
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    instructions =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    instructions
    |> Enum.reduce_while({1, 0, [], 20}, &run_inst/2)
    |> Enum.sum()
    |> IO.inspect()
  end
end

defmodule Day10.Solution2 do
  def run_inst({:addx_end, count}, x, cycles, crt, insts) do
    # start cycle. begin executing
    cycles = cycles + 1
    # during cycle

    # draw pixel in crt
    crt = draw_crt(crt, x, cycles)

    # end of cycle
    x = x + count
    case insts do
      [inst | tail] -> run_inst(inst, x, cycles, crt, tail)
      [] -> Enum.reverse crt
    end
  end

  def run_inst({:addx, count}, x, cycles, crt, instructions) do
    # start cycle. begin executing
    cycles = cycles + 1
    # during cycle

    # draw pixel in crt
    crt = draw_crt(crt, x, cycles)

    # end of cycle
    run_inst({:addx_end, count}, x, cycles, crt, instructions)
  end

  def run_inst({:noop}, x, cycles, crt, insts) do
    # start cycle. begin executing
    cycles = cycles + 1
    # during cycle

    # draw pixel in crt
    crt = draw_crt(crt, x, cycles)

    # end of cycle
    case insts do
      [inst | tail] -> run_inst(inst, x, cycles, crt, tail)
      [] -> Enum.reverse crt
    end
  end

  defp draw_crt(crt, x, cycles) do
    position = cycles - 1
    position = position - div(position, 40) * 40

    pixel = cond do
      x - 1 <= position and position <= x + 1 -> '#'
      true -> '.'
    end
    [pixel | crt]
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    instructions = [head | tail] =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    run_inst(head, 1, 0, [], tail)
    |> Enum.chunk_every(40)
    |> Enum.map(&Enum.join/1)
    |> IO.inspect(limit: :infinity)
  end
end

Day10.Solution2.run("input.txt")
