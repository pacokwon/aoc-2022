defmodule Util do
  def parse_line(line) do
    line
    |> String.split(~r/\D+/, trim: true)
    |> Stream.map(&String.to_integer/1)
    |> Stream.chunk_every(2)
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.flat_map(fn [[x1, y1], [x2, y2]] ->
      for x <- x1..x2, y <- y1..y2, do: {x, y}
    end)
  end

  def parse(lines) do
    lines
    |> Enum.map(&parse_line/1)
  end

  def log(obj) do
    IO.inspect(obj, charlist: false)
    obj
  end
end

defmodule Day14.Solution1 do
  # if something is inside {500, 0}, then we're over
  def fall(%{{500, 0} => val}, _bottom, _pos) when not is_nil(val) do
    nil
  end

  def fall(state, bottom, pos = {x, y}) do
    # fall to the bottom. there are three candidates
    #
    #   # {x, y}
    # .....
    candidate = Enum.find([{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}], &(!state[&1]))
    case candidate do
      # all candidates are blocked
      nil -> {state, Map.put(state, pos, :sand)}
      {_, y} when y > bottom -> nil
      _ -> fall(state, bottom, candidate)
    end
  end

  def run(filename) do
    parsed = filename
      |> File.stream!()
      |> Stream.flat_map(&Util.parse_line/1)
      |> Map.new(fn x -> {x, :rock} end)

    bottom = parsed
      |> Map.keys()
      |> Enum.max_by(&elem(&1, 1))
      |> elem(1)

    parsed
    |> Stream.unfold(&fall(&1, bottom, {500, 0}))
    |> Enum.to_list()
    |> length()
    |> IO.inspect()
  end
end

defmodule Day14.Solution2 do
  # if something is inside {500, 0}, then we're over
  def fall(%{{500, 0} => val}, _bottom, _pos) when not is_nil(val) do
    nil
  end

  def fall(state, bottom, pos = {x, y}) do
    # fall to the bottom. there are three candidates
    #
    #   # {x, y}
    # .....
    candidate = Enum.find([{x, y + 1}, {x - 1, y + 1}, {x + 1, y + 1}], &(!state[&1]))
    case candidate do
      # all candidates are blocked
      nil -> {state, Map.put(state, pos, :sand)}
      {_, y} when y > bottom -> nil
      _ -> fall(state, bottom, candidate)
    end
  end

  def put_bottom(parsed, bottom) do
    # 500, 0 -> 500, bottom
    #
    # ex>
    #       + (500, 0)
    #      ...
    #     .....
    #    .......
    #    ^  ^~~~ (500, 3)
    #    ~~~~~~~ (497, 3) = (500 - 3, 3)

    (500 - bottom)..(500 + bottom)
    |> Enum.map(&{&1, bottom})
    |> Map.new(&{&1, :rock})
    |> Map.merge(parsed)
  end

  def run(filename) do
    parsed = filename
      |> File.stream!()
      |> Stream.flat_map(&Util.parse_line/1)
      |> Map.new(fn x -> {x, :rock} end)

    bottom = parsed
      |> Map.keys()
      |> Enum.max_by(&elem(&1, 1))
      |> elem(1)
      |> Kernel.+(2)

    parsed
    |> put_bottom(bottom)
    |> Stream.unfold(&fall(&1, bottom, {500, 0}))
    |> Enum.to_list()
    |> length()
    |> IO.inspect()
  end
end

Day14.Solution2.run("input.txt")
