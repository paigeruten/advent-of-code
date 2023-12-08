pipes = DATA.readlines.map(&:strip).reject(&:empty?).map do |line|
  line.split('/').map(&:to_i)
end

bridges = pipes.select { |p| p.include?(0) }.map { |p| [p, p.max] }
final_bridges = []

loop do
  next_bridges = []
  bridges.each do |bridge|
    link = bridge.pop
    extended_bridge = false
    pipes.each do |pipe|
      if pipe.include?(link) and !bridge.include?(pipe)
        next_link = (pipe - [link]).first || link
        next_bridges.push(bridge + [pipe, next_link])
        extended_bridge = true
      end
    end
    final_bridges << bridge unless extended_bridge
  end
  if next_bridges.empty?
    final_bridges += bridges
    break
  end
  bridges = next_bridges
end

max_len = final_bridges.map { |bridge| bridge.length }.max
longests = final_bridges.select { |bridge| bridge.length == max_len }
p longests.map { |bridge| bridge.flatten.sum }.max

__END__
31/13
34/4
49/49
23/37
47/45
32/4
12/35
37/30
41/48
0/47
32/30
12/5
37/31
7/41
10/28
35/4
28/35
20/29
32/20
31/43
48/14
10/11
27/6
9/24
8/28
45/48
8/1
16/19
45/45
0/4
29/33
2/5
33/9
11/7
32/10
44/1
40/32
2/45
16/16
1/18
38/36
34/24
39/44
32/37
26/46
25/33
9/10
0/29
38/8
33/33
49/19
18/20
49/39
18/39
26/13
19/32
