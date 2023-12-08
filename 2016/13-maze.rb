require 'set'

PUZZLE_INPUT = 1350
PUZZLE_DEST = [31, 39]

def is_empty(x, y)
  return false if x < 0 || y < 0
  @is_empty ||= {}
  if @is_empty[[x, y]].nil?
    k = x*x + 3*x + 2*x*y + y + y*y
    k += PUZZLE_INPUT
    @is_empty[[x, y]] = (k.to_s(2).count("1") % 2 == 0)
  end
  @is_empty[[x, y]]
end

def draw_map(path)
  0.upto(path.map(&:last).max+2) do |y|
    0.upto(path.map(&:first).max+2) do |x|
      if is_empty(x, y)
        if path.include? [x, y]
          print ?O
        else
          print ?.
        end
      else
        print ?#
      end
    end
    puts
  end
end

been = Set.new
been.add [1, 1]

paths = [[[1, 1]]]
loop do
  new_paths = []
  paths.each do |path|
    x, y = path.last
    [[x, y-1], [x+1, y], [x, y+1], [x-1, y]].each do |x2, y2|
      if is_empty(x2, y2) && !been.member?([x2, y2])
        new_path = path.dup
        new_path << [x2, y2]
        new_paths << new_path
        been.add [x2, y2]
        if [x2, y2] == PUZZLE_DEST
          draw_map(new_path)
          exit
        end
      end
    end
  end
  paths = new_paths
end

