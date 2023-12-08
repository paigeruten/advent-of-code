matches = 0

a = 722
b = 354
40_000_000.times do
  a = (a * 16807) % 2147483647
  b = (b * 48271) % 2147483647

  if (a & 0xffff) == (b & 0xffff)
    matches += 1
  end
end

p matches
