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

def mark(map, y, x, region)
  map[y][x] = region
  [[y-1,x], [y,x+1], [y+1,x], [y,x-1]].each do |ny, nx|
    if ny >= 0 and nx >= 0 and map[ny] and map[ny][nx] == '#'
      mark(map, ny, nx, region)
    end
  end
end

map = rows.map { |row| row.map { |cell| {0=>'.',1=>'#'}[cell] }}

regions = 0
map.length.times do |y|
  map[y].length.times do |x|
    if map[y][x] == '#'
      regions += 1
      mark(map, y, x, regions.to_s)
    end
  end
end

p regions

__END__
stpzcrnm
