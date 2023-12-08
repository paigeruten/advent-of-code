row = "^..^^.^^^..^^.^...^^^^^....^.^..^^^.^.^.^^...^.^.^.^.^^.....^.^^.^.^.^.^.^.^^..^^^^^...^.....^....^.".chars.to_a

total = row.count ?.

39.times do |iter|
  l = ?.
  r = row[1]
  row.length.times do |i|
    new_value = ((l == ?^) ^ (r == ?^)) ? ?^ : ?.
    row[i], l, r = new_value, row[i], row[i+2]
    total += 1 if new_value == ?.
  end
end

p total

