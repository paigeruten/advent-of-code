adapters = DATA.readlines.map(&:to_i)
adapters.sort!

diffs = Hash.new(0)
last_adapter = 0
adapters.each do |adapter|
  diff = adapter - last_adapter
  diffs[diff] += 1

  last_adapter = adapter
end

# built-in adapter always a distance of 3
diffs[3] += 1

p (diffs[1] * diffs[3])

__END__
76
51
117
97
7
77
63
18
137
10
23
14
130
131
8
91
17
29
2
36
110
35
113
30
112
61
83
122
28
75
124
82
101
135
42
44
128
32
55
85
119
114
72
111
107
123
54
3
98
96
11
62
22
49
37
1
104
43
24
31
129
69
4
21
48
39
9
38
58
125
81
89
65
90
118
64
25
138
16
78
92
102
88
95
132
47
50
15
68
84
136
103
