defmodule Util do
  defp parse_line("R " <> count) do
    {:right, String.to_integer(count)}
  end
  defp parse_line("L " <> count) do
    {:left, String.to_integer(count)}
  end
  defp parse_line("U " <> count) do
    {:up, String.to_integer(count)}
  end
  defp parse_line("D " <> count) do
    {:down, String.to_integer(count)}
  end

  def parse(lines) do
    lines |> Enum.map(&parse_line/1)
  end

  def log(obj) do
    IO.inspect(obj)
    obj
  end
end

# Original
# ......
# ....H.
# ...T..
# ......
# s.....

# Class 1
# predicate: is the new position `safe`?
# ......  ......  ......
# ...H..  ......  ......
# ...T..  ...H..  ...TH.
# ......  ......  ......
# s.....  s.....  s.....

# Class 2
# predicate: does delta contain a 0?
# ......  ...H..
# ......  ......
# ...T.H  ...T..
# ......  ......
# s.....  s.....

# Class 3
# predicate: is delta {1, 2} or {2, 1}?
# ......  ....H.
# .....H  ......
# ...T..  ...T..
# ......  ......
# s.....  s.....

# Class 4
# predicate: is delta {2, 2}?
# .....H
# ......
# ...T..
# ......
# s.....

defmodule Day9.Solution1 do
  def get_move_info(dir) do
    case dir do
      :left -> {0, -1}
      :right -> {0, 1}
      :up -> {-1, 0}
      :down -> {1, 0}
    end
  end

  defp safe?({hx, hy}, {tx, ty}) do
    delta = {abs(hx - tx), abs(hy - ty)}
    (hx == tx and hy == ty) or delta == {1, 0} or delta == {0, 1} or delta == {1, 1}
  end

  def move(head = {hx, hy}, tail = {tx, ty}, dir) do
    {dx, dy} = get_move_info(dir)

    new_head = {nhx, nhy} = {hx + dx, hy + dy}
    new_delta = {abs(hx + dx - tx), abs(hy + dy - ty)}

    cond do
      hx == tx and hy == ty -> {new_head, tail}
      # Class 1
      safe?(new_head, tail) -> {new_head, tail}
      # Class 2 & Class 4
      Enum.member?([{2, 0}, {0, 2}, {2, 2}], new_delta) ->
        {new_head, {tx + div(nhx - tx, 2), ty + div(nhy - ty, 2)}}
      # Class 3
      true -> {new_head, head}
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

    # Enum.reduce(parsed, {0, 0}, fn cmd, pos -> move(pos, cmd) |> Util.log() end)

    Enum.reduce(instructions, {{0, 0}, {0, 0}, MapSet.new()}, fn {dir, count}, {head, tail, point_set} ->
      1..count
      |> Enum.reduce({head, tail, point_set}, fn _, {h, t, ps} ->
        {new_head, new_tail} = move(h, t, dir)
        {new_head, new_tail, MapSet.put(ps, new_tail)}
      end)
    end)
    |> then(&elem(&1, 2))
    |> MapSet.size()
    |> IO.inspect()
  end
end

defmodule Day9.Solution2 do
  def get_move_info(dir) do
    case dir do
      :left -> {0, -1}
      :right -> {0, 1}
      :up -> {-1, 0}
      :down -> {1, 0}
    end
  end

  defp safe?({hx, hy}, {tx, ty}) do
    delta = {abs(hx - tx), abs(hy - ty)}
    (hx == tx and hy == ty) or delta == {1, 0} or delta == {0, 1} or delta == {1, 1}
  end

  def move_tail(new_head = {nhx, nhy}, tail = {tx, ty}) do
    delta = {abs(nhx - tx), abs(nhy - ty)}

    cond do
      # Class 1
      safe?(new_head, tail) -> tail
      # Class 2 & Class 4
      Enum.member?([{2, 0}, {0, 2}, {2, 2}], delta) ->
        {tx + div(nhx - tx, 2), ty + div(nhy - ty, 2)}
      # Class 3
      true ->
        {delta_x, delta_y} = {nhx - tx, nhy - ty}
        dx = if rem(delta_x, 2) == 0 do div(delta_x, 2) else delta_x end
        dy = if rem(delta_y, 2) == 0 do div(delta_y, 2) else delta_y end
        {tx + dx, ty + dy}
    end
  end

  # return the new list of heads in their respective positions after an instruction,
  # BUT in reverse order.
  # the reversal should be done from the callee
  defp move_heads([{hx, hy} | rest], dir) do
    {dx, dy} = get_move_info(dir)
    new_head = {dx + hx, dy + hy}

    rest
    |> Enum.reduce([new_head], fn cur, acc = [new_head | _] ->
      new_tail = move_tail(new_head, cur)
      [new_tail | acc]
    end)
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

    # initial positions for heads
    heads = for _ <- 1..10, do: {0, 0}

    # run each instruction line by line.
    instructions
    |> Enum.reduce({heads, MapSet.new()}, fn {dir, count}, {new_heads, point_set} ->
      1..count
      |> Enum.reduce({new_heads, point_set}, fn _, {nhs, ps} -> # run a single instruction, `count` times
        heads_in_reverse = [h | _] = move_heads(nhs, dir)
        # put the new tail in the set.
        {Enum.reverse(heads_in_reverse), MapSet.put(ps, h)}
      end)
    end)
    |> then(&elem(&1, 1)) # extract the set
    |> MapSet.size()
    |> IO.inspect()
  end
end

Day9.Solution2.run("input.txt")
