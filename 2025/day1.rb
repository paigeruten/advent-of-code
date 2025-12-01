lines = File.readlines(ARGV.first)

rotations = lines.map { it.tr('LR', '-+').to_i }

dial_position = 50
zeros_landed_on = 0
zeros_passed = 0

rotations.each do |rotation|
  next_dial_position = dial_position + rotation
  zeros_passed += 1 if dial_position > 0 and next_dial_position <= 0
  zeros_passed += next_dial_position.abs / 100

  dial_position = next_dial_position % 100
  zeros_landed_on += 1 if dial_position.zero?
end

puts "Part 1: #{zeros_landed_on}"
puts "Part 2: #{zeros_passed}"
