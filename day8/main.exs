defmodule Util do
  def parse(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> :array.from_list()
  end

  defp parse_line(line) do
    line
    |> String.to_charlist()
    |> Enum.map(&(&1 - ?0))
    |> :array.from_list()
  end
end

defmodule Day8.Solution1 do
  defp movements(direction, size) do
    case direction do
      # { points, move_x, move_y }
      :down -> {0..(size-1) |> Enum.map(&({0, &1})), 1, 0}
      :up -> {0..(size-1) |> Enum.map(&({size - 1, &1})), -1, 0}
      :left -> {0..(size-1) |> Enum.map(&({&1, 0})), 0, 1}
      :right -> {0..(size-1) |> Enum.map(&({&1, size - 1})), 0, -1}
    end
  end

  # count the number of trees visible when scanned from `direction`
  def count_scanned_from(direction, array) do
    size = :array.size(array)
    {points, mx, my} = movements(direction, size)

    points
    |> Enum.reduce(MapSet.new(), fn {x, y}, point_set ->
      # iterate `size` times
      # mutate the state according to mx, my

      # state is {new_x, new_y, tallest, set of points}
      Enum.reduce(0..(size - 1), {x, y, -1, point_set}, fn _, {new_x, new_y, tallest, point_set} ->
        tree_height = :array.get(new_y, :array.get(new_x, array))
        if tree_height > tallest do
          {new_x + mx, new_y + my, tree_height, MapSet.put(point_set, {new_x, new_y})}
        else
          {new_x + mx, new_y + my, tallest, point_set}
        end
      end)
      |> then(&elem(&1, 3))
    end)
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    array =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    [:down, :up, :left, :right]
    |> Enum.map(&count_scanned_from(&1, array))
    |> Enum.reduce(&MapSet.union/2)
    |> then(&MapSet.size/1)
    |> IO.inspect()
  end
end

defmodule Day8.Solution2 do
  defp get_viewing_points(direction, x, y, size) do
    case direction do
      :down -> (x+1)..(size-1)//1 |> Enum.map(&({&1, y}))
      :up -> (x-1)..0//-1 |> Enum.map(&({&1, y}))
      :left -> (y-1)..0//-1 |> Enum.map(&({x, &1}))
      :right -> (y+1)..(size-1)//1 |> Enum.map(&({x, &1}))
    end
  end

  # count distance until first blocking tree
  def count_distance(points, array, my_height) do
    points
    |> Enum.reduce_while(0, fn {x, y}, count ->
      tree_height = :array.get(y, :array.get(x, array))
      # IO.inspect("tree: #{tree_height}, my: #{my_height}")
      if tree_height >= my_height do
        {:halt, count + 1}
      else
        {:cont, count + 1}
      end
    end)
  end

  def get_scenic_score({x, y}, array) do
    size = :array.size(array)
    my_height = :array.get(y, :array.get(x, array))

    [:down, :up, :left, :right]
    |> Enum.map(&get_viewing_points(&1, x, y, size))
    |> Enum.map(&count_distance(&1, array, my_height))
    |> Enum.product()
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    array =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    size = :array.size(array)

    (for x <- 1..(size-2), y <- 1..(size-2), do: {x, y})
    |> Enum.map(&get_scenic_score(&1, array))
    |> Enum.max()
    |> IO.inspect()
  end
end

Day8.Solution2.run("input.txt")
