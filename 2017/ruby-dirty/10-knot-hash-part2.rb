lens = DATA.read.strip.chars.map(&:ord)
lens += [17, 31, 73, 47, 23]

list = (0..255).to_a

pos = 0
skip = 0
64.times do
  lens.each do |len|
    list.take(len).reverse + list[len..-1]
    from = pos
    to = (pos + len) % 256
    if from <= to
      list = list[0...from] + list[from...to].reverse + list[to..-1]
    else
      list.rotate!(pos)
      list = list.take(len).reverse + list[len..-1]
      list.rotate!(-pos)
    end
    pos += len + skip
    skip += 1
  end
end

hash = []
16.times do |i|
  hash.push(list[(i*16)...((i+1)*16)].inject(:^))
end

puts(hash.map { |byte| "%02x" % [byte] }.join)

__END__
183,0,31,146,254,240,223,150,2,206,161,1,255,232,199,88
