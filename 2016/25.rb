$thresh = ARGV.first.to_i

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
  elsif line =~ /^out (-?\d+)$/
    program << [:out, $1.to_i]
  elsif line =~ /^out ([abcd])$/
    program << [:out, $1.to_sym]
  else
    puts "!!! PARSE ERROR: #{line}"
    exit
  end
end

def execute(program, a_value = 0)
  regs = { :a => a_value, :b => 0, :c => 0, :d => 0 }
  pc = 0
  output = []
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
    when :out
      output << (inst[1].is_a?(Symbol) ? regs[inst[1]] : inst[1])
      return false if output.length >= 2 && output[-2] == output[-1]
      return true if output.length == $thresh
    else
      puts "!!! INVALID INSTRUCTION"
      exit
    end
    pc += 1
  end
end

i = -1
begin
  i += 1
  p i
end until execute(program, i)

__END__
cpy a d
cpy 7 c
cpy 362 b
inc d
dec b
jnz b -2
dec c
jnz c -5
cpy d a
jnz 0 0
cpy a b
cpy 0 a
cpy 2 c
jnz b 2
jnz 1 6
dec b
dec c
jnz c -4
inc a
jnz 1 -7
cpy 2 b
jnz c 2
jnz 1 4
dec b
dec c
jnz 1 -4
jnz 0 0
out b
jnz a -19
jnz 1 -21
