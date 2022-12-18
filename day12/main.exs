# On this day, I take advantage of erlang's digraph module

defmodule Util do
  def parse_line(line) do
    line
    |> String.to_charlist()
    |> :array.from_list()
  end

  def parse(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> :array.from_list()
  end

  def write_array(array, i, j, val) do
    :array.set(i, :array.set(j, val, :array.get(i, array)), array)
  end

  def read_array(array, i, j) do
    :array.get(j, :array.get(i, array))
  end

  # {height, width}
  def dimension(array) do
    {:array.size(array), :array.size(:array.get(0, array))}
  end

  def log(obj) do
    IO.inspect(obj)
    obj
  end
end

defmodule Day12.Solution1 do
  @dxy [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    heightmap =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    {height, width} = Util.dimension(heightmap)

    {start, finish} = Enum.reduce(0..(height - 1), {nil, nil}, fn i, acc ->
      Enum.reduce(0..(width - 1), acc, fn j, {s, e} ->
        case Util.read_array(heightmap, i, j) do
          ?S -> {{i, j}, e}
          ?E -> {s, {i, j}}
          _ -> {s, e}
        end
      end)
    end)

    heightmap = Util.write_array(heightmap, elem(start, 0), elem(start, 1), ?a)
    heightmap = Util.write_array(heightmap, elem(finish, 0), elem(finish, 1), ?z)

    graph = :digraph.new()
    for i <- (0..(height - 1)), j <- (0..(width - 1)) do
      :digraph.add_vertex(graph, {i, j})
    end

    for i <- (0..(height - 1)), j <- (0..(width - 1)) do
      h = Util.read_array(heightmap, i, j)

      @dxy
      |> Stream.map(fn {dx, dy} -> {i + dx, j + dy} end)
      |> Stream.filter(fn {x, y} ->
        0 <= x and x < height and 0 <= y and y < width
      end)
      |> Stream.filter(fn {x, y} ->
        val = Util.read_array(heightmap, x, y)
        h >= val or h + 1 == val
      end)
      |> Enum.each(fn {x, y} ->
        :digraph.add_edge(graph, {i, j}, {x, y})
      end)
    end

    :digraph.get_short_path(graph, start, finish)
    |> length()
    |> Kernel.-(1)
    |> IO.inspect()
  end
end

defmodule Day12.Solution2 do
  @dxy [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    heightmap =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    {height, width} = Util.dimension(heightmap)

    {start, finish} = Enum.reduce(0..(height - 1), {nil, nil}, fn i, acc ->
      Enum.reduce(0..(width - 1), acc, fn j, {s, e} ->
        case Util.read_array(heightmap, i, j) do
          ?S -> {{i, j}, e}
          ?E -> {s, {i, j}}
          _ -> {s, e}
        end
      end)
    end)

    heightmap = Util.write_array(heightmap, elem(start, 0), elem(start, 1), ?a)
    heightmap = Util.write_array(heightmap, elem(finish, 0), elem(finish, 1), ?z)

    graph = :digraph.new()
    for i <- (0..(height - 1)), j <- (0..(width - 1)) do
      val = Util.read_array(heightmap, i, j)
      :digraph.add_vertex(graph, {i, j}, val)
    end

    for i <- (0..(height - 1)), j <- (0..(width - 1)) do
      h = Util.read_array(heightmap, i, j)

      @dxy
      |> Stream.map(fn {dx, dy} -> {i + dx, j + dy} end)
      |> Stream.filter(fn {x, y} ->
        0 <= x and x < height and 0 <= y and y < width
      end)
      |> Stream.filter(fn {x, y} ->
        val = Util.read_array(heightmap, x, y)
        h >= val or h + 1 == val
      end)
      |> Enum.each(fn {x, y} ->
        :digraph.add_edge(graph, {i, j}, {x, y})
      end)
    end

    graph
    |> :digraph.vertices()
    |> Stream.filter(fn v -> {v, ?a} == :digraph.vertex(graph, v) end)
    |> Stream.map(&:digraph.get_short_path(graph, &1, finish))
    |> Stream.filter(fn
      false -> false
      _ -> true
    end)
    |> Stream.map(&length/1)
    |> Stream.map(fn x -> x - 1 end)
    |> Enum.min()
    |> IO.inspect()
  end
end

Day12.Solution2.run("input.txt")
