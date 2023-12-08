target = DATA.read.to_i

def done(x, y)
  p(x.abs + y.abs)
  exit
end

dim = 3
n = 2
x = 1
y = 0
loop do
  (dim-2).times { y -= 1; n += 1; done(x, y) if n == target }
  (dim-1).times { x -= 1; n += 1; done(x, y) if n == target }
  (dim-1).times { y += 1; n += 1; done(x, y) if n == target }
  dim.times { x += 1; n += 1; done(x, y) if n == target }

  dim += 2
end

__END__
347991
