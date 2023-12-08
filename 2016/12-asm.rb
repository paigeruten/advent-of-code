C_VALUE = 1

puts "#include <stdio.h>"
puts
puts "int a = 0, b = 0, c = #{C_VALUE}, d = 0;"
puts
puts "int main() {"

DATA.each.with_index do |line, pc|
  puts "line#{pc}:"
  if line =~ /^cpy ([abcd]|-?\d+) ([abcd])$/
    puts "  #$2 = #$1;"
  elsif line =~ /^cpy (-?\d+) ([abcd])$/
    puts "  #$2 = #$1;"
  elsif line =~ /^inc ([abcd])$/
    puts "  #$1++;"
  elsif line =~ /^dec ([abcd])$/
    puts "  #$1--;"
  elsif line =~ /^jnz ([abcd]|-?\d+) (-?\d+)$/
    puts "  if (#$1) goto line#{pc + $2.to_i};"
  else
    puts "!!! PARSE ERROR: #{line}"
    exit
  end
end

puts
puts "  printf(\"%d\\n\", a);"
puts "  return 0;"
puts "}"
puts

__END__
cpy 1 a
cpy 1 b
cpy 26 d
jnz c 2
jnz 1 5
cpy 7 c
inc d
dec c
jnz c -2
cpy a c
inc a
dec b
jnz b -2
cpy c b
dec d
jnz d -6
cpy 17 c
cpy 18 d
inc a
dec d
jnz d -2
dec c
jnz c -5
