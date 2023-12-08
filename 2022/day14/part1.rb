map = {}
source = [500, 0]

def drop_sand!(map, source, max_y)
  x, y = source

  loop do
    if y + 1 > max_y
      return nil
    elsif map[[x, y + 1]].nil?
      y += 1
    elsif map[[x - 1, y + 1]].nil?
      x -= 1
      y += 1
    elsif map[[x + 1, y + 1]].nil?
      x += 1
      y += 1
    else
      map[[x, y]] = :sand
      return [x, y]
    end
  end
end

max_y = 0
File.readlines("input").each do |line|
  last_x = nil
  last_y = nil
  line.scan(/(\d+),(\d+)/).each do |x, y|
    x, y = x.to_i, y.to_i

    max_y = y if y > max_y

    if x == last_x
      (y..last_y).step(last_y - y <=> 0).each do |step_y|
        map[[x, step_y]] = :rock
      end
    elsif y == last_y
      (x..last_x).step(last_x - x <=> 0).each do |step_x|
        map[[step_x, y]] = :rock
      end
    end

    last_x, last_y = x, y
  end
end

sand_at_rest = 0
sand_at_rest += 1 while drop_sand!(map, source, max_y)

p sand_at_rest
