program = []
DATA.readlines.each do |line|
  program << line.strip.split
end

def value(regs, arg)
  if arg =~ /^[a-z]+$/
    regs[arg]
  else
    arg.to_i
  end
end

pc = 0
regs = Hash.new(0)
last = nil
loop do
  op, x, y = program[pc]
  case op
  when "snd"
    last = value(regs, x)
  when "rcv"
    if value(regs, x) != 0
      p last
      exit
    end
  when "set"
    regs[x] = value(regs, y)
  when "add"
    regs[x] += value(regs, y)
  when "mul"
    regs[x] *= value(regs, y)
  when "mod"
    regs[x] %= value(regs, y)
  when "jgz"
    if value(regs, x) > 0
      pc += value(regs, y) - 1
    end
  else
    puts "invalid instruction"
  end
  pc += 1
end

__END__
set i 31
set a 1
mul p 17
jgz p p
mul a 2
add i -1
jgz i -2
add a -1
set i 127
set p 464
mul p 8505
mod p a
mul p 129749
add p 12345
mod p a
set b p
mod b 10000
snd b
add i -1
jgz i -9
jgz a 3
rcv b
jgz b -1
set f 0
set i 126
rcv a
rcv b
set p a
mul p -1
add p b
jgz p 4
snd a
set a b
jgz 1 3
snd b
set f 1
add i -1
jgz i -11
snd a
jgz f -16
jgz a -19
