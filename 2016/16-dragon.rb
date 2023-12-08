INPUT = '10111100110001111'
LENGTH = 35651584

def generate(a)
  b = a.reverse.tr("01", "10")
  a << ?0
  a << b
end

data = INPUT
while data.length < LENGTH
  generate(data)
  p data.length
end
data = data[0...LENGTH]

puts "!!! Generated."

checksum = data
while checksum.length % 2 == 0
  new_checksum = ""
  checksum.scan(/../).each do |pair|
    if pair[0] == pair[1]
      new_checksum << ?1
    else
      new_checksum << ?0
    end
  end
  checksum = new_checksum
  p checksum.length
end

puts checksum

