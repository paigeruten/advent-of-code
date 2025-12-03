banks = File.readlines(ARGV.first).map { it.chomp.chars.map(&:to_i) }

def next_best_battery(bank, len)
  max = nil
  max_idx = nil
  0.upto(bank.length - len).each do |idx|
    max, max_idx = bank[idx], idx if max.nil? || bank[idx] > max
  end
  max_idx
end

def max_joltage(bank, len)
  batteries = []
  len.times do |i|
    battery_idx = next_best_battery(bank, len - i)
    batteries << bank[battery_idx]
    bank = bank[(battery_idx + 1)..]
  end
  batteries.map(&:to_s).join.to_i
end

part_1_total = banks.sum { max_joltage(it, 2) }
part_2_total = banks.sum { max_joltage(it, 12) }

puts "Part 1: #{part_1_total}"
puts "Part 2: #{part_2_total}"
