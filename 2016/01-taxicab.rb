require 'set'

INPUT = 'L4, L1, R4, R1, R1, L3, R5, L5, L2, L3, R2, R1, L4, R5, R4, L2, R1, R3, L5, R1, L3, L2, R5, L4, L5, R1, R2, L1, R5, L3, R2, R2, L1, R5, R2, L1, L1, R2, L1, R1, L2, L2, R4, R3, R2, L3, L188, L3, R2, R54, R1, R1, L2, L4, L3, L2, R3, L1, L1, R3, R5, L1, R5, L1, L1, R2, R4, R4, L5, L4, L1, R2, R4, R5, L2, L3, R5, L5, R1, R5, L2, R4, L2, L1, R4, R3, R4, L4, R3, L4, R78, R2, L3, R188, R2, R3, L2, R2, R3, R1, R5, R1, L1, L1, R4, R2, R1, R5, L1, R4, L4, R2, R5, L2, L5, R4, L3, L2, R1, R1, L5, L4, R1, L5, L1, L5, L1, L4, L3, L5, R4, R5, R2, L5, R5, R5, R4, R2, L1, L2, R3, R5, R5, R5, L2, L1, R4, R3, R1, L4, L2, L3, R2, L3, L5, L2, L2, L1, L2, R5, L2, L2, L3, L1, R1, L4, R2, L4, R3, R5, R3, R4, R1, R5, L3, L5, L5, L3, L2, L1, R3, L4, R3, R2, L1, R3, R1, L2, R4, L3, L3, L3, L1, L2'

COMPASS = 'NESW'
DXY = {?N => [0, -1], ?E => [1, 0], ?S => [0, 1], ?W => [-1, 0]}

facing = 0
x = 0
y = 0
been = Set.new
been.add [x, y]

dirs = INPUT.split(', ').map { |s| [s[0], s[1..-1].to_i] }
dirs.each do |lr, n|
  case lr
  when ?R
    facing = (facing + 1) % 4
  when ?L
    facing = (facing - 1) % 4
  end

  dx, dy = DXY[COMPASS[facing]]

  n.times do
    x += dx
    y += dy

    if been.member? [x, y]
      puts (x.abs + y.abs)
      exit
    else
      been.add [x, y]
    end
  end
end

