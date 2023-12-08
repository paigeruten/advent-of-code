def knot_hash(input)
  lens = input.strip.chars.map(&:ord)
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

  hash.map { |byte| "%02x" % [byte] }.join
end

base_input = DATA.read.strip
rows = []
128.times do |row|
  rows[row] = []
  hash = knot_hash("#{base_input}-#{row}")
  hash.chars.each do |nibble|
    n = nibble.to_i(16)
    rows[row] << (n >> 3)
    rows[row] << ((n >> 2) & 1)
    rows[row] << ((n >> 1) & 1)
    rows[row] << (n & 1)
  end
end

total_used = 0
rows.each do |row|
  total_used += row.count(1)
end

p total_used

__END__
stpzcrnm
