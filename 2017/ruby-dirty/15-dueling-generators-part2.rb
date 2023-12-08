$backlog = {:a => [], :b => []}
$matches = 0
$pairs = 0
def judge(ab, val)
  $backlog[ab] << val
  if !$backlog[:a].empty? and !$backlog[:b].empty?
    $pairs += 1
    a, b = $backlog[:a].shift, $backlog[:b].shift
    if (a & 0xffff) == (b & 0xffff)
      $matches += 1
    end
  end
end

a = 722
b = 354
while $pairs < 5_000_000
  a = (a * 16807) % 2147483647
  judge(:a, a) if a % 4 == 0

  b = (b * 48271) % 2147483647
  judge(:b, b) if b % 8 == 0
end

p $matches
