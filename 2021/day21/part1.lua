local die = {
  current = 1,
  rolls = 0,
  roll = function (self)
    local value = self.current

    self.current = self.current + 1
    if self.current > 100 then self.current = 1 end

    self.rolls = self.rolls + 1

    return value
  end,
}

local score1, score2 = 0, 0
local position1, position2 = 2, 7

while true do
  position1 = (position1 + die:roll() + die:roll() + die:roll() - 1) % 10 + 1
  position2 = (position2 + die:roll() + die:roll() + die:roll() - 1) % 10 + 1

  score1 = score1 + position1
  score2 = score2 + position2

  if score1 >= 1000 or score2 >= 1000 then
    if score1 >= score2 then
      print(score2 * die.rolls)
    else
      print(score1 * die.rolls)
    end
    break
  end
end
