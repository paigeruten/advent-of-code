n = DATA.read.to_i

buf = [0]
len = 1
pos = 0

50000000.times do |i|
  pos = (pos + n) % len
  if pos < 10
    buf.insert(pos + 1, i + 1)
  end
  len += 1
  pos += 1
end

p buf[buf.index(0) + 1]

__END__
377
