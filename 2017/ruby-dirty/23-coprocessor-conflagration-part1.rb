program = []
DATA.readlines.map(&:strip).reject(&:empty?).map(&:split).each do |op, arg1, arg2|
  arg1 = (arg1 =~ /^-?\d+$/) ? arg1.to_i : arg1.to_sym
  arg2 = (arg2 =~ /^-?\d+$/) ? arg2.to_i : arg2.to_sym
  program << [op.to_sym, arg1, arg2]
end

def value(regs, arg)
  arg.is_a?(Numeric) ? arg : regs[arg]
end

mul_invoked = 0
regs = Hash.new(0)
pc = 0
while pc >= 0 and pc < program.length
  op, arg1, arg2 = program[pc]
  case op
  when :set
    regs[arg1] = value(regs, arg2)
  when :sub
    regs[arg1] -= value(regs, arg2)
  when :mul
    mul_invoked += 1
    regs[arg1] *= value(regs, arg2)
  when :jnz
    if value(regs, arg1) != 0
      pc += value(regs, arg2) - 1
    end
  end
  pc += 1
end

p mul_invoked

__END__
set b 67
set c b
jnz a 2
jnz 1 5
mul b 100
sub b -100000
set c b
sub c -17000
set f 1
set d 2
set e 2
set g d
mul g e
sub g b
jnz g 2
set f 0
sub e -1
set g e
sub g b
jnz g -8
sub d -1
set g d
sub g b
jnz g -13
jnz f 2
sub h -1
set g b
sub g c
jnz g 2
jnz 1 3
sub b -17
jnz 1 -23
