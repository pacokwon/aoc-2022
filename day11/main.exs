defmodule Monkey do
  defstruct [:id, :items, :on_true, :on_false, :divisor, :inspect, :inspect_count]

  def receive_item(monkey, item) do
    items = :queue.in(item, monkey.items)
    %{monkey | items: items}
  end
end

defmodule Util do
  def parse_monkey(lines) do
    [
      <<_::bytes-size(7), num::bytes-size(1), _::binary>>,
      "  Starting items: " <> items,
      "  Operation: new = old " <> op_rest,
      "  Test: divisible by " <> divisor,
      "    If true: throw to monkey " <> true_monkey,
      "    If false: throw to monkey " <> false_monkey
      | tail
    ] = lines

    id = String.to_integer(num)

    items = items
      |> String.split(", ")
      |> Enum.map(&String.to_integer/1)
      |> :queue.from_list()

    operation =
      case op_rest do
        "* old" ->
          fn old -> old * old end

        "+ old" ->
          fn old -> old + old end

        "* " <> operand ->
          operand = String.to_integer(operand)
          fn old -> old * operand end

        "+ " <> operand ->
          operand = String.to_integer(operand)
          fn old -> old + operand end
      end

    divisor = String.to_integer(divisor)
    true_monkey = String.to_integer(true_monkey)
    false_monkey = String.to_integer(false_monkey)

    monkey = %Monkey{
      id: id,
      items: items,
      inspect: operation,
      inspect_count: 0,
      divisor: divisor,
      on_true: true_monkey,
      on_false: false_monkey
    }

    {monkey, tail}
  end

  def parse(lines, monkeys) do
    {monkey, lines} = parse_monkey(lines)
    monkeys = Map.put(monkeys, monkey.id, monkey)

    case lines do
      [] -> monkeys
      ["" | rest] -> parse(rest, monkeys)
    end
  end

  def parse(lines) do
    parse(lines, %{})
  end

  def log(obj) do
    IO.inspect(obj)
    obj
  end
end

defmodule Day11.Solution1 do
  # inspect an item, give it to a recipient, then return the new `monkeys` map
  def inspect_item(monkeys, monkey_id, item) do
    monkey = monkeys[monkey_id]

    new_item = item
      |> monkey.inspect.()
      |> div(3)

    recipient_id = cond do
      rem(new_item, monkey.divisor) == 0 -> monkey.on_true
      true -> monkey.on_false
    end

    # IO.inspect("Monkey #{monkey_id} popped item #{item}. It became #{new_item} and threw it to #{recipient_id}")
    recipient = Monkey.receive_item(monkeys[recipient_id], new_item)
    %{monkeys | recipient_id => recipient}
  end

  # do `monkey_id`s action and return the new `monkeys` map
  def monkey_action(monkeys, monkey_id, items) do
    # recurse until this monkey's items are depleted.
    cond do
      :queue.is_empty(items) ->
        monkey = monkeys[monkey_id]
        # replace the queue with an empty one and return
        new_monkey = %{monkey | items: :queue.new(), inspect_count: monkey.inspect_count + :queue.len(monkey.items)}
        %{monkeys | monkey_id => new_monkey}
      true ->
        {{:value, item}, new_items} = :queue.out(items)
        new_monkeys = inspect_item(monkeys, monkey_id, item)
        monkey_action(new_monkeys, monkey_id, new_items)
    end
  end

  def single_round(monkeys, [monkey_id | rest]) do
    new_monkeys = monkey_action(monkeys, monkey_id, monkeys[monkey_id].items)
    single_round(new_monkeys, rest)
  end

  def single_round(monkeys, []) do
    monkeys
  end

  def multiple_rounds(monkeys, last_monkey_id, current, until) do
    new_monkeys = single_round(monkeys, 0..last_monkey_id |> Enum.to_list())
    current = current + 1
    cond do
      current == until -> new_monkeys
      true -> multiple_rounds(new_monkeys, last_monkey_id, current, until)
    end
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    monkeys =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    last_monkey_id = Map.keys(monkeys) |> Enum.max()

    monkeys = multiple_rounds(monkeys, last_monkey_id, 0, 20)

    Map.values(monkeys)
    |> Enum.map(&Map.get(&1, :inspect_count))
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
    |> IO.inspect()
  end
end

defmodule Day11.Solution2 do
  # inspect an item, give it to a recipient, then return the new `monkeys` map
  def inspect_item(monkeys, monkey_id, item) do
    monkey = monkeys[monkey_id]

    new_item = item
      |> monkey.inspect.()
      |> rem(9699690) # LCM of all tests

    recipient_id = cond do
      rem(new_item, monkey.divisor) == 0 -> monkey.on_true
      true -> monkey.on_false
    end

    # IO.inspect("Monkey #{monkey_id} popped item #{item}. It became #{new_item} and threw it to #{recipient_id}")
    recipient = Monkey.receive_item(monkeys[recipient_id], new_item)
    %{monkeys | recipient_id => recipient}
  end

  # do `monkey_id`s action and return the new `monkeys` map
  def monkey_action(monkeys, monkey_id, items) do
    # recurse until this monkey's items are depleted.
    cond do
      :queue.is_empty(items) ->
        monkey = monkeys[monkey_id]
        # replace the queue with an empty one and return
        new_monkey = %{monkey | items: :queue.new(), inspect_count: monkey.inspect_count + :queue.len(monkey.items)}
        %{monkeys | monkey_id => new_monkey}
      true ->
        {{:value, item}, new_items} = :queue.out(items)
        new_monkeys = inspect_item(monkeys, monkey_id, item)
        monkey_action(new_monkeys, monkey_id, new_items)
    end
  end

  def single_round(monkeys, [monkey_id | rest]) do
    new_monkeys = monkey_action(monkeys, monkey_id, monkeys[monkey_id].items)
    single_round(new_monkeys, rest)
  end

  def single_round(monkeys, []) do
    monkeys
  end

  def multiple_rounds(monkeys, last_monkey_id, current, until) do
    new_monkeys = single_round(monkeys, 0..last_monkey_id |> Enum.to_list())
    current = current + 1
    cond do
      current == until -> new_monkeys
      true -> multiple_rounds(new_monkeys, last_monkey_id, current, until)
    end
  end

  def run(filename) do
    file =
      case File.open(filename) do
        {:ok, file} -> file
        _ -> raise RuntimeError
      end

    monkeys =
      IO.read(file, :all)
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Util.parse()

    last_monkey_id = Map.keys(monkeys) |> Enum.max()

    monkeys = multiple_rounds(monkeys, last_monkey_id, 0, 10000)

    Map.values(monkeys)
    |> Enum.map(&Map.get(&1, :inspect_count))
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
    |> IO.inspect()
  end
end

Day11.Solution1.run("input.txt")
