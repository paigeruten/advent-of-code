def compare(a, b)
  return a <=> b if a.is_a?(Integer) && b.is_a?(Integer)

  a = [a] if a.is_a?(Integer)
  b = [b] if b.is_a?(Integer)

  (0...a.length).each do |i|
    return 1 if b[i].nil?
    order = compare(a[i], b[i])
    return order unless order.zero?
  end

  a.length <=> b.length
end

sum_correct_order = 0

File.read("input").split("\n\n").each.with_index do |pair, pair_idx|
  a, b = pair.lines

  if compare(eval(a), eval(b)) < 0
    sum_correct_order += (pair_idx + 1)
  end
end

p sum_correct_order
