discs = [[13, 1], [19, 10], [3, 2], [7, 1], [5, 3], [17, 5], [11, 0]]

time = 0
disc_pos = discs.map(&:last)
loop do
  if disc_pos.map.with_index { |pos, i| (pos + i + 1) % discs[i][0] }.all?(&:zero?)
    p time
    exit
  end

  disc_pos.map!.with_index { |pos, i| (pos + 1) % discs[i][0] }
  time += 1
end

