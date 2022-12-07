defmodule Util do
  def split_by(enumerable, predicate) do
    split_by_helper([], enumerable, predicate)
  end

  defp split_by_helper(a, [bh | bt], predicate) do
    if predicate.(bh) do
      {Enum.reverse(a), bt}
    else
      split_by_helper([bh | a], bt, predicate)
    end
  end

  defp split_by_helper(a, [], _) do
    {Enum.reverse(a), []}
  end
end

defmodule Day5.Solution1 do
  def operate_command([count, from, to], deques) do
    from = from - 1
    to = to - 1

    from_deque = Enum.at(deques, from)
    to_deque = Enum.at(deques, to)

    {new_from_deque, new_to_deque} =
      Enum.reduce(1..count, {from_deque, to_deque}, fn _, {from_deque, to_deque} ->
        {popped, new_x} = Deque.popleft(from_deque)
        {new_x, Deque.appendleft(to_deque, popped)}
      end)

    deques
    |> Enum.with_index()
    |> Enum.map(fn
      {_, ^from} -> new_from_deque
      {_, ^to} -> new_to_deque
      {d, _} -> d
    end)
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    lines =
      IO.read(file, :all)
      |> String.split("\n")
      |> Stream.drop(-1)
      |> Enum.to_list()

    {head, tail} = Util.split_by(lines, &(&1 == ""))
    head = head |> Enum.drop(-1)

    cargo_zipped =
      head
      |> Stream.map(fn line ->
        line
        |> String.to_charlist()
        |> Enum.drop(1)
        |> Enum.take_every(4)
      end)
      |> Stream.zip()
      |> Enum.to_list()

    total_crates = cargo_zipped |> Enum.map(&tuple_size/1) |> Enum.sum()

    deques =
      cargo_zipped
      |> Stream.map(fn line ->
        line
        |> Tuple.to_list()
        |> Enum.drop_while(&(&1 == ?\s))
        |> Enum.into(Deque.new(total_crates))
      end)
      |> Enum.to_list()

    commands =
      tail
      |> Enum.map(fn line ->
        line
        |> String.split(" ")
        |> Stream.drop(1)
        |> Stream.take_every(2)
        |> Stream.map(&String.to_integer/1)
        |> Enum.to_list()
      end)

    commands
    |> Enum.reduce(deques, &operate_command/2)
    |> Enum.map(&elem(Deque.popleft(&1), 0))
    |> IO.inspect()
  end
end

defmodule Day5.Solution2 do
  def operate_command([count, from, to], deques) do
    from = from - 1
    to = to - 1

    from_deque = Enum.at(deques, from)
    to_deque = Enum.at(deques, to)

    {popped_list, new_from_deque} =
      Enum.reduce(1..count, {[], from_deque}, fn _, {acc, deque} ->
        {popped, new_deque} = Deque.popleft(deque)
        {[popped | acc], new_deque}
      end)

    new_to_deque =
      Enum.reduce(popped_list, to_deque, fn el, deque ->
        deque |> Deque.appendleft(el)
      end)

    deques
    |> Enum.with_index()
    |> Enum.map(fn
      {_, ^from} -> new_from_deque
      {_, ^to} -> new_to_deque
      {d, _} -> d
    end)
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    lines =
      IO.read(file, :all)
      |> String.split("\n")
      |> Stream.drop(-1)
      |> Enum.to_list()

    {head, tail} = Util.split_by(lines, &(&1 == ""))
    head = head |> Enum.drop(-1)

    cargo_zipped =
      head
      |> Stream.map(fn line ->
        line
        |> String.to_charlist()
        |> Enum.drop(1)
        |> Enum.take_every(4)
      end)
      |> Stream.zip()
      |> Enum.to_list()

    total_crates = cargo_zipped |> Enum.map(&tuple_size/1) |> Enum.sum()

    deques =
      cargo_zipped
      |> Stream.map(fn line ->
        line
        |> Tuple.to_list()
        |> Enum.drop_while(&(&1 == ?\s))
        |> Enum.into(Deque.new(total_crates))
      end)
      |> Enum.to_list()

    commands =
      tail
      |> Enum.map(fn line ->
        line
        |> String.split(" ")
        |> Stream.drop(1)
        |> Stream.take_every(2)
        |> Stream.map(&String.to_integer/1)
        |> Enum.to_list()
      end)

    commands
    |> Enum.reduce(deques, &operate_command/2)
    |> Enum.map(&elem(Deque.popleft(&1), 0))
    |> IO.inspect()
  end
end
