print "#include <stdio.h>\nint main() { int a,b,c,d;a=b=c=d=0;"
ARGF.each.with_index do |line, nr|
  puts "L#{nr}:"
  cmd = line.split
  case cmd[0]
  when "cpy" then puts "#{cmd[2]}=#{cmd[1]};"
  when "inc" then puts "++#{cmd[1]};"
  when "dec" then puts "--#{cmd[1]};"
  when "jnz" then puts "if(#{cmd[1]}) goto L#{nr+cmd[2].to_i};"
  end
end
puts "printf(\"%d\\n\", a); }"

