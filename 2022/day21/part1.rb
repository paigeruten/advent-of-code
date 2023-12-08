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
  value = monkeys[monkey]
  if value.is_a? Integer
    value
  else
    value.operands.map { |operand| resolve(operand, monkeys) }.inject(value.op)
  end
end

p resolve(:root, monkeys)