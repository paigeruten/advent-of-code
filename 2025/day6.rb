lines = File.readlines(ARGV.first).map(&:chomp)
  
horizontal_problems = lines.map(&:split).transpose
horizontal_total = horizontal_problems.sum { it[0..-2].map(&:to_i).inject(it[-1]) }

vertical_total = 0
numbers = []
lines.map(&:chars).map(&:reverse).transpose.map(&:join).map(&:strip).reject(&:empty?).each do |column|
  numbers << column.to_i
  if column.end_with?("+", "*")
    vertical_total += numbers.inject(column[-1])
    numbers = []
  end
end

puts "Part 1: #{horizontal_total}"
puts "Part 2: #{vertical_total}"
