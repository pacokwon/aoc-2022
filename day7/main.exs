# https://hajto.github.io/erlang-digraphs/
defmodule Util do
  def parse_input(lines) do
    {cache, command, result} =
      lines
      |> Enum.reduce({[], nil, []}, fn line, {cache, command, result} ->
        if String.starts_with?(line, "$ ") do
          cmd =
            case String.split(line, " ") do
              ["$", "ls"] -> "ls"
              ["$", "cd", arg] -> {"cd", arg}
            end

          case {command, cache} do
            {nil, _} -> {[], cmd, result}
            {_, []} -> {[], cmd, [command | result]}
            _ -> {[], cmd, [{command, cache} | result]}
          end
        else
          result_line =
            case String.split(line, " ") do
              ["dir", name] -> {"dir", name}
              [num, name] -> {"file", name, String.to_integer(num)}
            end

          {[result_line | cache], command, result}
        end
      end)

    result =
      case command do
        "ls" -> [{command, cache} | result]
        _ -> [command | result]
      end

    Enum.reverse(result)
  end

  def construct_tree(parsed) do
    graph = :digraph.new()
    # root
    :digraph.add_vertex(graph, "", {:dir, 0})

    Enum.reduce(parsed, [""], fn
      {"ls", list}, l ->
        Enum.each(list, fn
          {"dir", name} ->
            full_name_parent = Enum.join(l, "/")
            full_name = name <> "/" <> full_name_parent
            v = :digraph.add_vertex(graph, full_name, {:dir, 0})
            :digraph.add_edge(graph, full_name_parent, v)

          {"file", name, size} ->
            full_name_parent = Enum.join(l, "/")
            full_name = name <> "/" <> full_name_parent
            v = :digraph.add_vertex(graph, full_name, {:file, size})
            :digraph.add_edge(graph, full_name_parent, v)
        end)

        l

      {"cd", ".."}, [_ | t] ->
        t

      {"cd", dest}, path ->
        [dest | path]
    end)

    Enum.each(:digraph_utils.postorder(graph), fn node ->
      {v, {_, size}} = :digraph.vertex(graph, node)

      with [parent] <- :digraph.in_neighbours(graph, v) do
        {_, {_, parent_size}} = :digraph.vertex(graph, parent)
        :digraph.add_vertex(graph, parent, {:dir, parent_size + size})
      end
    end)

    graph
  end
end

# [
#   {"ls",
#    [
#      {"dir", "d"},
#      {"file", "c.dat", "8504156"},
#      {"file", "b.txt", "14848514"},
#      {"dir", "a"}
#    ]},
#   {"cd", "a"},
#   {"ls",
#    [
#      {"file", "h.lst", "62596"},
#      {"file", "g", "2557"},
#      {"file", "f", "29116"},
#      {"dir", "e"}
#    ]},
#   {"cd", "e"},
#   {"ls", [{"file", "i", "584"}]},
#   {"cd", ".."},
#   {"cd", ".."},
#   {"cd", "d"},
#   {"ls",
#    [
#      {"file", "k", "7214296"},
#      {"file", "d.ext", "5626152"},
#      {"file", "d.log", "8033020"},
#      {"file", "j", "4060174"}
#    ]}
# ]
defmodule Day7.Solution1 do
  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    graph =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse_input()
      |> Enum.drop(1)
      |> Util.construct_tree()

    Enum.reduce(:digraph_utils.postorder(graph), 0, fn node, acc ->
      with {_, {:dir, size}} <- :digraph.vertex(graph, node) do
        if size <= 100_000 do
          acc + size
        else
          acc
        end
      else
        _ -> acc
      end
    end)
    |> IO.inspect()
  end
end

defmodule Day7.Solution2 do
  @required_space 30000000
  @disk_size      70000000

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    graph =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse_input()
      |> Enum.drop(1)
      |> Util.construct_tree()

    # query root
    {_, {_, current_total_size}} = :digraph.vertex(graph, "")
    current_space = @disk_size - current_total_size
    space_needed = @required_space - current_space

    :digraph_utils.postorder(graph)
    |> Stream.map(fn node -> :digraph.vertex(graph, node) end)
    |> Stream.filter(fn
      {_, {:dir, _}} -> true
      _ -> false
    end)
    |> Stream.map(fn {name, {:dir, size}} -> {name, size} end)
    |> Enum.to_list()
    |> Enum.sort_by(&elem(&1, 1))
    |> Enum.find(fn {name, size} -> size >= space_needed end)
    |> IO.inspect()
  end
end

Day7.Solution2.run("input.txt")
