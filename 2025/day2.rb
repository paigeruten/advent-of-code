input = File.read(ARGV.first)

ranges = input.split(',').map { |range| Range.new(*range.split('-').map(&:to_i)) }

def is_valid_simple?(n)
  digits = n.to_s
  len = digits.length

  len.odd? || digits[0...len/2] != digits[len/2..]
end

def is_valid?(n)
  digits = n.to_s.chars
  len = digits.length

  return true if len == 1

  (1..len/2).each do |chunk_len|
    if len % chunk_len == 0
      first_chunk = digits[0...chunk_len]
      if digits.each_slice(chunk_len).drop(1).all? { it == first_chunk }
        return false
      end
    end
  end

  true
end

invalid_ids_sum_simple = 0
invalid_ids_sum_actual = 0

ranges.each do |range|
  range.each do |id|
    invalid_ids_sum_simple += id unless is_valid_simple?(id)
    invalid_ids_sum_actual += id unless is_valid?(id)
  end
end

puts "Part 1: #{invalid_ids_sum_simple}"
puts "Part 2: #{invalid_ids_sum_actual}"
