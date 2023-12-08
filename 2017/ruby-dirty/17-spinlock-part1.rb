n = DATA.read.to_i

buf = [0]
pos = 0

2017.times do |i|
  pos = (pos + n) % buf.length
  buf.insert(pos + 1, i + 1)
  pos += 1
end

p buf[(pos + 1) % buf.length]

__END__
377
