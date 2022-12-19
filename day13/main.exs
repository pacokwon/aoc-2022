defmodule Util do
  defp parse_list("]" <> rest, _) do
    {[], rest}
  end

  # parse list without the first bracket
  # if the list is [1,2,3],
  # 1,2,3] will be fed as input
  defp parse_list(line, acc) do
    {first, rest} = parse_obj(line)

    case rest do
      "," <> rest ->
        {result, rest} = parse_list(rest, acc)
        {[first | result], rest}
      "]" <> rest ->
        {[first | acc], rest}
    end
  end

  defp parse_list(line) do
    parse_list(line, [])
  end

  defp parse_number(line) do
    Integer.parse(line)
  end

  defp parse_obj(line) do
    case line do
      "[" <> rest -> parse_list(rest)
      _ -> parse_number(line)
    end
  end

  defp parse_line(line) do
    "[" <> rest = line
    {result, ""} = parse_list(rest)
    result
  end

  defp parse_section(lines) do
    [line1, line2 | rest] = lines
    {{parse_line(line1), parse_line(line2)}, rest}
  end

  def parse(lines, results) do
    {section, rest} = parse_section(lines)

    case rest do
      ["" | rest] -> parse(rest, [section | results])
      [] -> Enum.reverse [section | results]
    end
  end

  def parse(lines) do
    parse(lines, [])
  end

  def compare(left, right) when is_integer(left) and is_integer(right) do
    cond do
      left < right -> :smaller
      left == right -> :equal
      left > right -> :larger
    end
  end

  def compare(left, right) when is_list(left) and is_list(right) do
    compare_list(left, right)
  end

  def compare(left, right) when is_integer(left) and is_list(right) do
    compare_list([left], right)
  end

  def compare(left, right) when is_list(left) and is_integer(right) do
    compare_list(left, [right])
  end

  def compare_list([], []) do
    :equal
  end

  def compare_list(_rl, []) do
    :larger
  end

  def compare_list([], _ll) do
    :smaller
  end

  def compare_list([lh|lt], [rh|rt]) do
    case compare(lh, rh) do
      :smaller -> :smaller
      :equal -> compare_list(lt, rt)
      :larger -> :larger
    end
  end

  def log(obj) do
    IO.inspect(obj, charlist: false)
    obj
  end
end

defmodule Day13.Solution1 do
  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    IO.read(file, :all)
    |> String.split("\n")
    |> Enum.drop(-1)
    |> Util.parse()
    |> Stream.with_index(1)
    |> Stream.filter(fn {{l, r}, _} ->
      case Util.compare(l, r) do
        :smaller -> true
        _ -> false
      end
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
    |> Util.log()
  end
end

defmodule Day13.Solution2 do
  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    IO.read(file, :all)
    |> String.split("\n")
    |> Enum.drop(-1)
    |> Util.parse()
    |> Enum.flat_map(fn {r1, r2} -> [r1, r2] end)
    |> then(&([[[2]], [[6]] | &1]))
    |> Enum.sort(fn o1, o2 ->
      case Util.compare(o1, o2) do
        :smaller -> true
        _ -> false
      end
    end)
    |> Enum.with_index(1)
    |> Enum.reduce({nil, nil}, fn {cur, index}, {d1, d2} ->
      cond do
        cur == [[2]] -> {index, d2}
        cur == [[6]] -> {d1, index}
        true -> {d1, d2}
      end
    end)
    |> Tuple.product()
    |> Util.log()
  end
end

Day13.Solution2.run("input.txt")
