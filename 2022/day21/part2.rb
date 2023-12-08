MathOp = Struct.new(:op, :operands)
monkeys = {}

File.readlines("input").each do |line|
  case line
  when /^(\w+): (\d+)$/
    monkeys[$1.to_sym] = $2.to_i
  when /^(\w+): (\w+) ([+\-*\/]) (\w+)$/
    monkeys[$1.to_sym] = MathOp.new($3.to_sym, [$2.to_sym, $4.to_sym])
  else
    raise "Invalid line '#{line.chomp}'"
  end
end

def resolve(monkey, monkeys)
  return nil if monkey == :humn

  value = monkeys[monkey]
  if value.is_a? Integer
    value
  else
    resolved_operands = value.operands.map { |operand| resolve(operand, monkeys) }
    return nil if resolved_operands.include? nil
    resolved_operands.inject(value.op)
  end
end

def fill_blank(monkey, result, monkeys)
  return result if monkey == :humn

  op = monkeys[monkey].op
  a, b = monkeys[monkey].operands.map { |o| resolve(o, monkeys) || o }
  case op
  when :+
    if a.is_a? Integer
      fill_blank(b, result - a, monkeys)
    else
      fill_blank(a, result - b, monkeys)
    end
  when :-
    if a.is_a? Integer
      fill_blank(b, a - result, monkeys)
    else
      fill_blank(a, result + b, monkeys)
    end
  when :*
    if a.is_a? Integer
      fill_blank(b, result / a, monkeys)
    else
      fill_blank(a, result / b, monkeys)
    end
  when :/
    if a.is_a? Integer
      fill_blank(b, a / result, monkeys)
    else
      fill_blank(a, result * b, monkeys)
    end
  end
end

monkeys[:root].op = :-
p fill_blank(:root, 0, monkeys)