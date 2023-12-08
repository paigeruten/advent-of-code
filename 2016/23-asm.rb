program = []
DATA.each.with_index do |line, pc|
  if line =~ /^cpy ([abcd]) ([abcd])$/
    program << [:cpy, $1.to_sym, $2.to_sym]
  elsif line =~ /^cpy (-?\d+) ([abcd])$/
    program << [:cpy, $1.to_i, $2.to_sym]
  elsif line =~ /^inc ([abcd])$/
    program << [:inc, $1.to_sym]
  elsif line =~ /^dec ([abcd])$/
    program << [:dec, $1.to_sym]
  elsif line =~ /^jnz ([abcd]) (-?\d+)$/
    program << [:jnz, $1.to_sym, $2.to_i]
  elsif line =~ /^jnz (-?\d+) (-?\d+)$/
    program << [:jnz, $1.to_i, $2.to_i]
  elsif line =~ /^jnz (-?\d+) ([abcd])$/
    program << [:jnz, $1.to_i, $2.to_sym]
  elsif line =~ /^jnz ([abcd]) ([abcd])$/
    program << [:jnz, $1.to_sym, $2.to_sym]
  elsif line =~ /^tgl ([abcd])$/
    program << [:tgl, $1.to_sym]
  elsif line =~ /^tgl (-?\d+)$/
    program << [:tgl, $1.to_i]
  elsif line =~ /^mul ([abcd]) ([abcd]) ([abcd])$/
    program << [:mul, $1.to_sym, $2.to_sym, $3.to_sym]
  elsif line =~ /^mul ([abcd]) ([abcd]) (-?\d+)$/
    program << [:mul, $1.to_sym, $2.to_sym, $3.to_i]
  else
    puts "!!! PARSE ERROR: #{line}"
    exit
  end
end

regs = { :a => 12, :b => 0, :c => 0, :d => 0 }
pc = 0
while pc < program.length
  inst = program[pc]
  case inst[0]
  when :cpy
    if inst[2].is_a?(Symbol)
      regs[inst[2]] = inst[1].is_a?(Symbol) ? regs[inst[1]] : inst[1]
    end
  when :inc
    regs[inst[1]] += 1 if inst[1].is_a?(Symbol)
  when :dec
    regs[inst[1]] -= 1 if inst[1].is_a?(Symbol)
  when :jnz
    if (inst[1].is_a?(Symbol) and regs[inst[1]] != 0) or (inst[1].is_a?(Integer) and inst[1] != 0)
      pc += (inst[2].is_a?(Symbol) ? regs[inst[2]] : inst[2]) - 1
    end
  when :tgl
    target = pc + (inst[1].is_a?(Symbol) ? regs[inst[1]] : inst[1])
    unless target < 0 or target >= program.length
      if program[target].length == 2
        if program[target][0] == :inc
          program[target][0] = :dec
        else
          program[target][0] = :inc
        end
      elsif program[target].length == 3
        if program[target][0] == :jnz
          program[target][0] = :cpy
        else
          program[target][0] = :jnz
        end
      else
        puts "!!! INVALID INSTRUCTION LENGTH"
        exit
      end
    end
  when :mul
    regs[inst[1]] = regs[inst[2]] * (inst[3].is_a?(Symbol) ? regs[inst[3]] : inst[3])
  else
    puts "!!! INVALID INSTRUCTION"
    exit
  end
  pc += 1
end

p regs[:a]

__END__
cpy a b
dec b
mul a a b
dec b
mul c b 2
tgl c
cpy -5 c
jnz 1 c
cpy 81 c
jnz 93 d
inc a
inc d
jnz d -2
inc c
jnz c -5
