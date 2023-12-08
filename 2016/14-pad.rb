require 'digest'

SALT = 'yjdafjpo'

def md5_stretched(index)
  hash = Digest::MD5.hexdigest("#{SALT}#{index}")
  2016.times { hash = Digest::MD5.hexdigest(hash) }
  hash
end

hashes = 0.upto(999).map { |i| md5_stretched(i) }

count = 0
i = 0
loop do
  cur = hashes[i % 1000]
  hashes[i % 1000] = md5_stretched(i + 1000)

  if cur =~ /(.)\1\1/ && hashes.any? { |hex| hex[$1 * 5] }
    count += 1
    if count == 64
      puts i
      exit
    end
  end
  i += 1
end

