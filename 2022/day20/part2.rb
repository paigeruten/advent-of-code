DECRYPTION_KEY = 811589153

ary = File.readlines("input").map.with_index do |num, idx|
  { num: num.to_i * DECRYPTION_KEY, orig_idx: idx }
end

10.times do |i|
  puts "Mixing... (#{i+1}/10)"

  (0...ary.length).each do |cur_idx|
    idx = ary.find_index { |v| v[:orig_idx] == cur_idx }

    num = ary[idx][:num]
    if num < 0
      (-num % (ary.length-1)).times do
        prev_idx = (idx - 1) % ary.length
        ary[idx], ary[prev_idx] = ary[prev_idx], ary[idx]
        idx = prev_idx
      end
    else
      (num % (ary.length-1)).times do
        next_idx = (idx + 1) % ary.length
        ary[idx], ary[next_idx] = ary[next_idx], ary[idx]
        idx = next_idx
      end
    end
  end
end

nums = ary.map { |v| v[:num] }
zero_idx = nums.find_index(0)

first = nums[(zero_idx + 1000) % nums.length]
second = nums[(zero_idx + 2000) % nums.length]
third = nums[(zero_idx + 3000) % nums.length]

puts "\n#{first + second + third}"