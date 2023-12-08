# Rewrote the assembly program by hand in Ruby, and refactored until it became
# clear it was just counting how many numbers were prime/composite in a range.
# Once the unnecessary inner loop was removed, the program took less than a
# second to run instead of forever.

debug_mode = false

if debug_mode
  range = 67..67
else
  range = 106700..123700
end

num_composites = 0
range.step(17).each do |k|
  if k % 2 == 0
    num_composites += 1
  else
    (3...k).step(2).each do |d|
      if k % d == 0
        num_composites += 1
        break
      elsif d * d > k
        break
      end
    end
  end
end
p num_composites
