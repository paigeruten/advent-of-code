def look_and_say(seq)
  seq.scan(/((\d)\2*)/).map { |s,c| "#{s.length}#{c}" }.join
end

seq = "1321131112"
50.times do
  seq = look_and_say(seq)
end
p seq.length

