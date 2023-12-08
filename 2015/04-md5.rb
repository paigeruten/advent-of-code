require 'digest'

base = 'yzbqklnj'

i = 1
i += 1 until Digest::MD5.hexdigest("#{base}#{i}").start_with? '000000'
p i

