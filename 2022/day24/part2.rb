require 'set'
require 'pairing_heap' # priority queue implementation - https://github.com/mhib/pairing_heap

BLIZZARD_DIRECTIONS = {
  ">" => [1, 0],
  "v" => [0, 1],
  "<" => [-1, 0],
  "^" => [0, -1],
}

map = File.readlines("input").map(&:chomp)

width = map[0].length - 2
height = map.length - 2

num_blizzard_states = (width * height) / width.gcd(height)

blizzard_map = {}
(1..height).each do |y|
  (1..width).each do |x|
    (blizzard_map[[x, y]] ||= []) << map[y][x] if map[y][x] != "."
  end
end

blizzard_maps = [blizzard_map]
(1...num_blizzard_states).each do |t|
  prev_map = blizzard_maps[t - 1]
  new_map = {}
  blizzard_maps[t - 1].each do |pos, blizzards|
    blizzards.each do |blizzard|
      new_pos = pos.dup
      case blizzard
      when ">"
        if pos[0] == width
          new_pos[0] = 1
        else
          new_pos[0] += 1
        end
      when "<"
        if pos[0] == 1
          new_pos[0] = width
        else
          new_pos[0] -= 1
        end
      when "v"
        if pos[1] == height
          new_pos[1] = 1
        else
          new_pos[1] += 1
        end
      when "^"
        if pos[1] == 1
          new_pos[1] = height
        else
          new_pos[1] -= 1
        end
      end

      (new_map[new_pos] ||= []) << blizzard
    end
  end

  blizzard_maps[t] = new_map
end

def find_neighbours(node, blizzard_maps, width, height)
  t = (node[2] + 1) % blizzard_maps.length
  stage = node[3]

  [[0, 0], [1, 0], [-1, 0], [0, 1], [0, -1]].map do |dx, dy|
    x, y = node[0] + dx, node[1] + dy
    next if ([x, y] != [1, 0]) && ([x, y] != [width, height + 1]) && (
      x < 1 || x > width || y < 1 || y > height
    )
    next if blizzard_maps[t][[x, y]]

    stage += 1 if stage % 2 == 0 && x == width && y == height + 1
    stage += 1 if stage % 2 == 1 && x == 1 && y == 0

    [x, y, t, stage]
  end.compact
end

initial_node = [1, 0, 0, 0]
dist = {initial_node => 0}
visited = Set[]

queue = PairingHeap::MinPriorityQueue.new
queue.push(initial_node, 0)

loop do
  node = queue.pop
  visited.add(node)

  find_neighbours(node, blizzard_maps, width, height).each do |neighbour|
    next if visited.include?(neighbour)

    alt_dist = dist[node] + 1

    if dist[neighbour].nil?
      dist[neighbour] = alt_dist
      queue.push(neighbour, dist[neighbour])
    elsif alt_dist < dist[neighbour]
      dist[neighbour] = alt_dist
      queue.decrease_key(neighbour, alt_dist)
    end

    if neighbour[0] == width && neighbour[1] == height + 1 && neighbour[3] == 3
      p dist[neighbour]
      exit
    end
  end
end
