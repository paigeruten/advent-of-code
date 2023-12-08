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

def other(prog)
  if prog == 0
    1
  else
    0
  end
end

pc = [0, 0]
waiting = [false, false]
sent = [[], []]
regs = [Hash.new(0), Hash.new(0)]
regs[0]["p"] = 0
regs[1]["p"] = 1
prog = 0
num_sent = 0
loop do
  op, x, y = program[pc[prog]]
  case op
  when "snd"
    sent[prog].push(value(regs[prog], x))
    num_sent += 1 if prog == 1
  when "rcv"
    if !sent[other(prog)].empty?
      regs[prog][x] = sent[other(prog)].shift
      waiting[prog] = false
    else
      waiting[prog] = true
      if waiting[other(prog)]
        break
      end
    end
  when "set"
    regs[prog][x] = value(regs[prog], y)
  when "add"
    regs[prog][x] += value(regs[prog], y)
  when "mul"
    regs[prog][x] *= value(regs[prog], y)
  when "mod"
    regs[prog][x] %= value(regs[prog], y)
  when "jgz"
    if value(regs[prog], x) > 0
      pc[prog] += value(regs[prog], y) - 1
    end
  else
    puts "invalid instruction"
  end
  pc[prog] += 1 unless waiting[prog]
  prog = other(prog)
end

p num_sent

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
