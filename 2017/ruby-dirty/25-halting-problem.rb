states = {
  a: [[1, 1, :b], [0, -1, :c]],
  b: [[1, -1, :a], [1, -1, :d]],
  c: [[1, 1, :d], [0, 1, :c]],
  d: [[0, -1, :b], [0, 1, :e]],
  e: [[1, 1, :c], [1, -1, :f]],
  f: [[1, -1, :e], [1, 1, :a]]
}

state = :a
tape = Hash.new(0)
cursor = 0

12656374.times do
  value, move, next_state = states[state][tape[cursor]]

  tape[cursor] = value
  cursor += move
  state = next_state
end

p tape.values.count(1)
