require 'set'

list = DATA.read.split.map(&:to_i)

seen = Set.new
seen.add(list)

cycles = 0
loop do
  n = list.max
  i = list.index(n)
  list[i] = 0
  while n > 0
    i = (i+1) % 16
    list[i] += 1
    n -= 1
  end
  cycles += 1
  if seen.include?(list)
    p cycles
    exit
  end
  seen.add(list)
end

__END__
10  3 15  10  5 15  5 15  9 2 5 8 5 2 3 6
