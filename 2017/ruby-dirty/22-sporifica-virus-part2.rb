lines = DATA.readlines.map(&:strip).reject(&:empty?)

states = Hash.new(:clean)

y = -(lines.length / 2)
lines.each do |line|
  x = -(line.length / 2)
  line.chars.each do |c|
    if c == '#'
      states[[x, y]] = :infected
    end
    x += 1
  end
  y += 1
end

DIRECTIONS = [[0, -1], [1, 0], [0, 1], [-1, 0]]

x = 0
y = 0
dir = 0
infections_caused = 0

10_000_000.times do |i|
  puts "#{i/100_000}%" if i % 100_000 == 0

  states[[x, y]] =
    case states[[x, y]]
    when :clean
      dir = (dir - 1) % DIRECTIONS.length
      :weakened
    when :weakened
      infections_caused += 1
      :infected
    when :infected
      dir = (dir + 1) % DIRECTIONS.length
      :flagged
    when :flagged
      dir = (dir + 2) % DIRECTIONS.length
      :clean
    end

  x += DIRECTIONS[dir][0]
  y += DIRECTIONS[dir][1]
end

p infections_caused

__END__
.#.....##..##..###.###..#
..##..######.#.###.##.#.#
###..#..#####.##.##.#...#
###......##..###.#...#.#.
.#.###.##..#.####.#..#...
..#.#.#####...##.####.###
..#..#.#..###.#..###.###.
#########...#....##..#.#.
.###..#######..####...###
#####...#..##...###..##..
..#......##.#....#...####
.##.#..#####.#####.##.##.
####.##.###.#..#.#.#.....
#....##.####.#.#..#.#.##.
###...##...#.###.#.#.####
.#.#...#.#.##.##....##.#.
#..##.#.#..#....###..####
#####...#..#.###...##.###
##.#..####.###...#....###
###.#####.....#....#.##..
####.##.....######.#..#.#
.#.....####.##...###..##.
....########.#..###.#..##
##.##..#...#...##.#....##
.#.######.##....####.#.##
