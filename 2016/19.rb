NUM_ELVES = 3018458

all_elves = [1] * NUM_ELVES
elves = (0...NUM_ELVES).to_a

i = 0
until elves.length == 1 do
  across = (i + (elves.length / 2)) % elves.length
  all_elves[elves[i]] += all_elves[elves[across]]
  elves.delete_at(across)
  if across > i
    i = (i + 1) % elves.length
  else
    i %= elves.length
  end
  p elves.length if elves.length % 10000 == 0
end

p (elves.first + 1)

