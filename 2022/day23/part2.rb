elves = {}

File.readlines("input").each.with_index do |line, y|
  line.chomp.chars.each.with_index do |char, x|
    elves[[x, y]] = true if char == "#"
  end
end

DIRECTIONS = {
  n: [0, -1],
  ne: [1, -1],
  e: [1, 0],
  se: [1, 1],
  s: [0, 1],
  sw: [-1, 1],
  w: [-1, 0],
  nw: [-1, -1],
}

def move(pos, dir)
  delta = DIRECTIONS[dir]
  [pos[0] + delta[0], pos[1] + delta[1]]
end

def elf_by?(elves, pos, dir)
  elves[move(pos, dir)] != nil
end

direction_order = [
  [:n, :nw, :ne],
  [:s, :sw, :se],
  [:w, :nw, :sw],
  [:e, :ne, :se],
]

round = 1
loop do
  proposed_destinations = Hash.new(0)

  elves.keys.each do |elf_pos|
    next unless DIRECTIONS.keys.any? { |dir| elf_by?(elves, elf_pos, dir) }

    direction_order.each do |dirs|
      if dirs.all? { |dir| not elf_by?(elves, elf_pos, dir) }
        proposed = move(elf_pos, dirs.first)
        elves[elf_pos] = proposed
        proposed_destinations[proposed] += 1
        break
      end
    end
  end

  next_elves = {}
  at_least_one_elf_moved = false

  elves.each do |elf_pos, proposed|
    if !proposed.is_a?(Array) || proposed_destinations[proposed] > 1
      next_elves[elf_pos] = true
    else
      next_elves[proposed] = true
      at_least_one_elf_moved = true
    end
  end

  elves = next_elves
  direction_order.rotate!

  break unless at_least_one_elf_moved
  round += 1
end

p round
