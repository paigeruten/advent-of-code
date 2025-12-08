grid = File.readlines(ARGV.first).map(&:chomp).map(&:chars)
start_x = grid[0].index('S')

beams_x = [start_x]
num_splits = 0
grid[1..].each do |row|
  next_beams_x = []
  beams_x.each do |beam_x|
    if row[beam_x] == '^'
      next_beams_x << beam_x - 1
      next_beams_x << beam_x + 1
      num_splits += 1
    else
      next_beams_x << beam_x
    end
  end
  beams_x = next_beams_x.uniq
end

class QuantumManifold
  def initialize(grid)
    @grid = grid
    @memo = {}
  end

  def count_timelines(x, y)
    return @memo[[x, y]] if @memo[[x, y]]

    old_y = y
    y += 1 until y >= @grid.length || @grid[y][x] == '^'

    count = if y >= @grid.length
      1
    else
      self.count_timelines(x - 1, y) + self.count_timelines(x + 1, y)
    end

    old_y.upto(y).each do |cur_y|
      @memo[[x, cur_y]] = count
    end
    count
  end
end

manifold = QuantumManifold.new(grid)
num_timelines = manifold.count_timelines(start_x, 0)

puts "Part 1: #{num_splits}"
puts "Part 2: #{num_timelines}"
