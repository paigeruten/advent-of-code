require 'digest'

base = 'wtnhxymk'
i = 0
n = 0
password = Array.new(8)

while n != 8
  md5 = Digest::MD5.hexdigest("#{base}#{i}")
  if md5.start_with?('00000') && md5[5].to_i(16) <= 7 && password[md5[5].to_i].nil?
    puts md5
    password[md5[5].to_i] = md5[6]
    n += 1
  end
  i += 1
end

puts password.join

