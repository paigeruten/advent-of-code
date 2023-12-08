target = DATA.read.to_i

def done(n)
  p n
  exit
end

def find(x, y, grid)
  n = 0
  (-1..1).each do |i|
    (-1..1).each do |j|
      unless i == 0 and j == 0
        v = grid[[x+i,y+j]]
        n += v if v
      end
    end
  end
  grid[[x,y]] = n
  n
end

grid = {[0,0] => 1, [1,0] => 1}
dim = 3
n = 1
x = 1
y = 0
loop do
  (dim-2).times { y -= 1; n = find(x, y, grid); done(n) if n > target }
  (dim-1).times { x -= 1; n = find(x, y, grid); done(n) if n > target }
  (dim-1).times { y += 1; n = find(x, y, grid); done(n) if n > target }
  dim.times { x += 1; n = find(x, y, grid); done(n) if n > target }

  dim += 2
end

__END__
347991
