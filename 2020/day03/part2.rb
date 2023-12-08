rows = DATA.readlines.map(&:chomp)

result = 1
[[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]].each do |dx, dy|
  x = 0
  y = 0
  trees_encountered = 0
  loop do
    y += dy
    x += dx

    break if y >= rows.length

    row = rows[y]
    tile = row[x % row.length]
    trees_encountered += 1 if tile == ?#
  end
  result *= trees_encountered
end

p result

__END__
........#....#..##..#...#.....#
...............#....##........#
.#....##...##..#...............
.#.......#......#.##..##...#...
.....#.#....#..##...#.....#....
...#.#..##...###......#..#..#.#
.....#..##........#.##......#..
..##.....###.........##........
..............##..#.#.#.#......
.#....##..#.##.#....#..#.#..#..
.#.#....#.##.#...#....#.....#..
..#...#.#.....#....#.......##..
.#.#..##.....#...........#.....
.#.##...#.....#......#.##......
..#..#..........#.....#..###.#.
##....##....#.#...........#..#.
.....#.#.......#.#.#..#.##....#
...##.#....#..#.....#.........#
.....#........#.##...#.........
.....#................#.#...#..
...#....##.....##....#.......#.
....##.#.....#.#.......#.......
#...............#..#...........
.......###.#.......#.##....#.#.
..#........###........#......#.
.#.......#...##.....####....##.
..##.#....#.....#..#....#......
..#...#..#.#..##...#.....#.....
.#.......###.......#....#......
...#...#.......#........#...#.#
..#....#...#.......#.#..##.....
##............#.#..#..........#
.......###...##..#.....#....#..
##..######.#..#.......###....##
###..#...#.##......##....#...#.
..............##.###..........#
.....#........##.#.###....#....
..#...#.....##.#......#.#..#.#.
#....#.............#.#.........
.........##.#........#...#.....
..........#..##.#.#.....#..##..
........##......#..#..#...#.#..
.##.......#..#.#...#.####..#...
##...#........#.###...##....#..
....###.####...#..#..#......###
#....#....#.#.....##.........#.
#.......#....#....##...........
##...##.#.......#....#...#....#
....#....#........##..#.#..#.#.
..##.....##...#..........#...#.
.#.#.#...#.....##..#........#..
#....#.....#..........#....#...
...##.#.......#.#.........#....
##.##.........##.....##.....##.
##.#..##..#...##........##.....
.........##.......#....#...#...
.#.....#........####.#.#.....#.
...........##..#.###...........
..#....##....#...#.............
#.#............#.......#.......
.##........#...#..##.....#.#...
#.##..............##..##.......
##.........#......#......#..#..
##.#....#...#....##....#..#.##.
......#...#..#.#...#.#....#.##.
##.......#.....#.........#.....
...##...#................#.#...
....#.####...#.#.....##....##.#
#...#..#.#.##................##
.........##.....##...#..#......
......####....#.##.#.....#.....
...#..#.#....#.#.#..#..........
.....#........##...#.##....#.#.
..##......#...................#
.....#..#...............#..#...
....#........#..#.#...##...#.##
..#.#.......#.##.........#...#.
...##......#.#.................
.#....#...#.............##.#...
........#.##...#..#...###.....#
#....#.#........##....#......##
.###.......#..#..........#..#..
#....#..#....#........#...#...#
##.#.###.##.#...##.#......#.#.#
#..#..#..##........#..###.#...#
....#..#..#.....#...##....#...#
.......##.......#..#.##...##..#
.##....#..###................##
#...#.##.##...#.##......##.....
...##.....##..##...#..#........
...............##.....##.......
.#..#.#..#....#.....#..#...#...
.#....#..#........#.#...#.....#
##.....####..#......#..........
........#.........#.........#..
#...####....#.##...#....#...##.
.#....####..#...##..#......####
...........##.##..#.##...##....
..#..#.......#.##....#.#...#.##
#...........#..#...............
.......#.##..#.....##......#...
....##.#.##.....#...........#.#
.............#.##..#...#......#
#......#...........#........#..
#.#..#.............#...#.......
#.........##...#....#...##.....
##...#..#..#..#....#...........
.#.....#........#.....#.##..#.#
...#..............##.####.#..#.
##.....#..#.#..#..##...........
...#...#.......#...............
..#..................###..#..##
....###..........#.#..#...#.#.#
..#..#..#.#..........#.#......#
....#....#.#...#.###...##..#...
....#.......#...#....##........
.#.....#.......###....#........
....#..#..#.....#......#.......
......#...#..#....#.#.......#..
.##.#..#...#.#.#...........#...
..#....##.#....#.#....#...#.#.#
...##..#.......#....#.#.....##.
##.#......#.#.......##...#.....
......#...#.##..............#..
.##.........#......##.#..#....#
#.......#.....#...##...#..#...#
..#..##.......#......#......##.
#..##...###.#.#...........#....
##......#.....####..#..#....#.#
.......##...##.#...#...........
....#..#.##.#.....#.#....#.#...
....#.....#.....####...#..#.##.
.##..#..#..###...#....#.##.#.#.
..#.#.##..........##...........
#.##.#.#....#.##....#..#...##.#
#...#....#...###....#.......#..
.......#..#............#.......
................##.#.#.....#..#
..........................#....
.##....##...#.#....####..#....#
......#...#....#...#.##..###.#.
.........#............#.......#
.#.#..#........#..#.........#..
#..#...#......#.#....#..#.#....
...........#.................#.
.#.#..#...##..###......##....##
.#.#.##......####.........##...
..#....#.#..#................#.
##.......#....#.........##.#.#.
##..#.###...........#..#.#..#.#
...#............##.#....#......
...#................##.#..#....
....#..##.#...#.#.....#.......#
......#......#.#........#..##..
...##...#.....#.##.......#.....
##...#...#.............#..#....
..#...##.....#..........#..#.##
#.##...#..................#.###
.........#..........#.###...#.#
#..#.....#.#.#....#......#...#.
.............#.##..###.....#.##
..#..#.....#..#.............#..
.#.....##.#.#..#.........#.....
..#.......#....#.....##.#......
.#.........#..#....##...#.##...
.##..##................###....#
.#..##..............#...#......
.#..............#.##....##.....
.#......#..#..##..#...###.....#
................##...#.#..#...#
##.#.......#...................
....#.#.......#..#.##..........
....###............##...#......
.......#....#.#.....##.#.....#.
....#...............#.#........
..#.##....#.#.#......##..#.....
.##......#...#.#..#..#.......#.
....#...#........#.#..##.......
.##...###.#....#..........##..#
..#.......##..#.....###......#.
...#.#..##.#.#...........#.....
##........#.#..##.........#..#.
.....###.......#..#.#.....##.#.
..#...##.#..............#......
......#...#...............##.#.
##...#..#....#...#.####.##.....
...#............#.##...........
...#........##.#.##.......#....
...#..#..##....#...#......#..#.
#.....#..#......#.#.....##.#.#.
.....#.##......#...#..#..###..#
...........##..##.#.#..........
...#........##........##..##.#.
......###...#.....#..###.#..#..
#.....#.#....#...##....##.....#
.##....#......#.....#.#..##.##.
##....###.......#...##.......##
...##......#....###............
..#...#...#.#..#..........##.#.
#.#.###...#..#.....#....#.###..
..##.....#.#.#.......#.........
...####..#....#..#.........#...
.##...........#.##.#...#.#.##..
...#.#....#.##......#........#.
##....##....#..#...#..#.#......
#......#..#...#...#.#.#.#.####.
....##.#.#.....#.###........#..
....##..#.#.#.#....#....#.#..#.
..#.###..#............##..#.#..
...#...#..#...#.#.#.....#.....#
..........#.....#..#.......##.#
..............##...........#...
.......#.....#...#.....#.....#.
.#.###.....##......##....#...#.
.....#.........#.#....#........
..#.#....#.##...#.##....##...#.
...#......#.#.....#.......###..
#.##....##.....#.#.#...#......#
#..#...#..........#.........##.
....#.#.#.#.....#...###........
#.#..#...#......#...#.##...####
.#...#......#....##...#........
..#.........#............#...#.
##......#..#...#....#.##....#..
.#...##..#..##.#.#.#........#.#
.##.........###...#......#..###
...##.....##..#.#.........#....
...........##........#...#.....
..##..#...#..#..#.....#......#.
..#..#.#....#.....#..#.##...#..
#....#........##..........#.###
......#...#...#....#...##.#....
...#......#.#.....##......##...
#....#..##............#....#.#.
...#...##.#..........##........
......#.###......#...#.#.......
..................#.##..#..#..#
....#.....#...#.....#...#....#.
.#....##.#..#..#.....###.##...#
#.......#..#....##.##.#.....##.
..##........##...#.....#....##.
#.........#...........##.#.....
.#....#.#...##..###..........#.
....##..##....####...#......#..
##.##..#..#....#....####...#...
..#...............#.##.........
...#.#....#..#....#......#.....
.#..#...#........#...#.....##..
#.....###.......#.....#........
...#.##..#.......#....#........
....##..###.##...#.#....#.#....
#.####...#.......#.....#.#....#
#.......#......#.......#.#.#...
##....#......#..#...#..#..####.
.##.....#........#..#...#......
#.#.#....#....#...#.##..##.....
....#..#.........###.##.##.....
...##...##.###..#..##.....#.###
..###.......................#..
......##..#.#.........#......#.
.###......##....#.....#.......#
.....#..#..##........#......##.
..##.....#....#.#.............#
..##.........##.#..#.........##
......#......#.#......#........
.#...#..#......##...#..#....#..
...............###............#
#.####.#....#...#...........#.#
............................#.#
.#..#...#.#.#.###..##.....##...
....##...#.................##..
......##....#...............##.
.#......#.##.#..#.....##...##..
.............#........#......#.
#..........#.#....#####.#...#.#
.#.#...##..#.#...#.#..#.#..#...
#.##.......##......#.#.#....#..
##.....##.#.#.##..........##..#
....##..#.#.......#....#.##....
..#.#.#...#.....#.......#......
.#....#..#...........###.......
#.#...#.....#......#...#.....#.
#........#.#..........#...#.#..
...#...#....#.........#........
.....................#..##.....
...#......##........#.##.#.#.##
.............###...#.#...#..#..
.#..##........##....#...###..##
.#..#.#...............#.....##.
...........##.#....#..##.#....#
.##.#.#..#.#..#...#.#.#..#.#.##
.......#.#..#..#..#..#...#.....
.#......##............#.#..#...
..#...#..##..#..#...##......#..
...##......##....#............#
.......#.....##...##.#...#..#..
......#.......#..##.........#..
..#...#.#.....#.#.......#.#...#
.#......##.##.#.#.#.##..#....##
#.....#.........#.#....#....##.
.......#.........#....#..#.#.##
.....##....#..#.#.#...#.....##.
#####.#.......######......#....
..##.#.......#.#..............#
..#.##....#.....#...#.#...##...
.....#...#..#....#.#..#........
.#....#.#..#.#.#.##..#.......#.
....#..#..#..........##...#....
.......#.#......#........#.....
##.#.#.###....##.#..#..#....#..
#.##......#..#.......#.#...#...
..##...#.......#.......#...#...
........##.........#.#....#.#..
..#...#..##.#.#.#...#....#.....
.###......#........#....#...#..
.#.......##......###..##.......
#....#.#....#.##.........####..
......#..........#..##.....#...
.............#......#..##.#....
...................#....#...#..
.#..........#...#.#..##...#....
.....#...#..........##.##......
#...#..#.##........#...#.......