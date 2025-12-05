DIRECTIONS = [-1, 0, 1].product([-1, 0, 1])
  .reject { |dx, dy| dx == 0 && dy == 0 }

grid = File.readlines(ARGV.first).map(&:chomp).map(&:chars)

rolls = {}
grid.length.times do |y|
  grid[y].length.times do |x|
    if grid[y][x] == ?@
      rolls[[x, y]] = DIRECTIONS
        .map { |dx, dy| [x + dx, y + dy] }
        .count { |nx, ny| nx >= 0 && ny >= 0 && grid.dig(ny, nx) == ?@ }
    end
  end
end

num_removed = []
begin
  num_removed << 0
  next_rolls = rolls.dup
  rolls.select { |_, neighbours| neighbours < 4 }.each_key do |pos|
    next_rolls.delete(pos)
    num_removed[-1] += 1
    DIRECTIONS.map { |dx, dy| [pos[0] + dx, pos[1] + dy] }.each do |neighbour_pos|
      next_rolls[neighbour_pos] -= 1 if next_rolls[neighbour_pos]
    end
  end
  rolls = next_rolls
end until num_removed.last == 0

puts "Part 1: #{num_removed.first}"
puts "Part 2: #{num_removed.sum}"
