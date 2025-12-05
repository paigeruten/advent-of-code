ranges_input, ids_input = File.read(ARGV.first).split("\n\n")

ranges = ranges_input.lines.map { Range.new(*it.split('-').map(&:to_i)) }
ids = ids_input.lines.map(&:to_i)

def overlapping?(a, b)
  a.end >= b.begin && a.begin <= b.end
end

def merge_ranges(a, b)
  [a.begin, b.begin].min..[a.end, b.end].max
end

def merge_overlapping_ranges!(ranges)
  i = 0
  while i < ranges.length - 1
    found_overlap = false
    (i + 1).upto(ranges.length - 1).each do |j|
      next unless overlapping?(ranges[i], ranges[j])
      ranges[i] = merge_ranges(ranges[i], ranges[j])
      ranges.delete_at(j)
      found_overlap = true
      break
    end
    i += 1 unless found_overlap
  end
end

available_fresh_ingredients = ids.count { |id| ranges.any? { |range| range.include?(id) } }

merge_overlapping_ranges!(ranges)
all_possible_fresh_ingredients = ranges.sum { it.end - it.begin + 1 }

puts "Part 1: #{available_fresh_ingredients}"
puts "Part 2: #{all_possible_fresh_ingredients}"
