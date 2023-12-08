#string = "abcdefgh"
#REVERSE = false

string = "fbgdceah"
REVERSE = true

def rotate_str(str, dir, n)
  n %= str.length
  n = str.length - n if dir == 'right'
  n %= str.length

  str[n..-1] + str[0...n]
end

puts "  => #{string}"

lines = REVERSE ? DATA.to_a.reverse : DATA
lines.each do |line|
  line.chomp!
  puts line
  if line =~ /^swap position (\d+) with position (\d+)$/
    string[$1.to_i], string[$2.to_i] = string[$2.to_i], string[$1.to_i]
  elsif line =~ /^swap letter (\w) with letter (\w)$/
    string.tr!($1 + $2, $2 + $1)
  elsif line =~ /^rotate (left|right) (\d+) steps?$/
    dir = $1
    dir = {'left'=>'right','right'=>'left'}[dir] if REVERSE
    string = rotate_str(string, dir, $2.to_i)
  elsif line =~ /^rotate based on position of letter (\w)$/
    idx = string.index($1)
    if REVERSE
      string = rotate_str(string, 'left', {0=>9,1=>1,2=>6,3=>2,4=>7,5=>3,6=>8,7=>4}[idx])
    else
      if idx >= 4
        string = rotate_str(string, 'right', idx + 2)
      else
        string = rotate_str(string, 'right', idx + 1)
      end
    end
  elsif line =~ /^reverse positions (\d+) through (\d+)$/
    a, b = $1.to_i, $2.to_i
    string[a..b] = string[a..b].reverse
  elsif line =~ /^move position (\d+) to position (\d+)$/
    from, to = $1.to_i, $2.to_i
    from, to = to, from if REVERSE
    ch = string[from]
    string[from] = ""
    string[to] = ch + string[to].to_s
  else
    puts "!!! PARSE ERROR: #{line}"
  end
  puts "  => #{string}"
end

__END__
rotate right 3 steps
swap letter b with letter a
move position 3 to position 4
swap position 0 with position 7
swap letter f with letter h
rotate based on position of letter f
rotate based on position of letter b
swap position 3 with position 0
swap position 6 with position 1
move position 4 to position 0
rotate based on position of letter d
swap letter d with letter h
reverse positions 5 through 6
rotate based on position of letter h
reverse positions 4 through 5
move position 3 to position 6
rotate based on position of letter e
rotate based on position of letter c
rotate right 2 steps
reverse positions 5 through 6
rotate right 3 steps
rotate based on position of letter b
rotate right 5 steps
swap position 5 with position 6
move position 6 to position 4
rotate left 0 steps
swap position 3 with position 5
move position 4 to position 7
reverse positions 0 through 7
rotate left 4 steps
rotate based on position of letter d
rotate left 3 steps
swap position 0 with position 7
rotate based on position of letter e
swap letter e with letter a
rotate based on position of letter c
swap position 3 with position 2
rotate based on position of letter d
reverse positions 2 through 4
rotate based on position of letter g
move position 3 to position 0
move position 3 to position 5
swap letter b with letter d
reverse positions 1 through 5
reverse positions 0 through 1
rotate based on position of letter a
reverse positions 2 through 5
swap position 1 with position 6
swap letter f with letter e
swap position 5 with position 1
rotate based on position of letter a
move position 1 to position 6
swap letter e with letter d
reverse positions 4 through 7
swap position 7 with position 5
swap letter c with letter g
swap letter e with letter g
rotate left 4 steps
swap letter c with letter a
rotate left 0 steps
swap position 0 with position 1
reverse positions 1 through 4
rotate based on position of letter d
swap position 4 with position 2
rotate right 0 steps
swap position 1 with position 0
swap letter c with letter a
swap position 7 with position 3
swap letter a with letter f
reverse positions 3 through 7
rotate right 1 step
swap letter h with letter c
move position 1 to position 3
swap position 4 with position 2
rotate based on position of letter b
reverse positions 5 through 6
move position 5 to position 3
swap letter b with letter g
rotate right 6 steps
reverse positions 6 through 7
swap position 2 with position 5
rotate based on position of letter e
swap position 1 with position 7
swap position 1 with position 5
reverse positions 2 through 7
reverse positions 5 through 7
rotate left 3 steps
rotate based on position of letter b
rotate left 3 steps
swap letter e with letter c
rotate based on position of letter a
swap letter f with letter a
swap position 0 with position 6
swap position 4 with position 7
reverse positions 0 through 5
reverse positions 3 through 5
swap letter d with letter e
move position 0 to position 7
move position 1 to position 3
reverse positions 4 through 7
