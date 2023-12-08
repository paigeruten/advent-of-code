input = File.read("01-input.txt")
ups = 0
downs = 0
input.chars.each.with_index do |dir, idx|
  if dir == '('
    ups += 1
  else
    downs += 1
    if downs > ups
      puts (idx+1)
      exit
    end
  end
end
