dofile("../common.lua")

local ROLLS_DISTRIBUTION <const> = {
  [3] = 1,
  [4] = 3,
  [5] = 6,
  [6] = 7,
  [7] = 6,
  [8] = 3,
  [9] = 1,
}

memo = {}

local function count_wins(position1, position2, target1, target2)
  local memo_key = table.concat({position1, "|", position2, "|", target1, "|", target2})
  if memo[memo_key] then return table.unpack(memo[memo_key]) end

  local wins1, wins2 = 0, 0
  for roll1, multiplier1 in pairs(ROLLS_DISTRIBUTION) do
    local new_position1 = (position1 + roll1 - 1) % 10 + 1
    local new_target1 = target1 - new_position1
    if new_target1 <= 0 then
      wins1 = wins1 + multiplier1
    else
      for roll2, multiplier2 in pairs(ROLLS_DISTRIBUTION) do
        local new_position2 = (position2 + roll2 - 1) % 10 + 1
        local new_target2 = target2 - new_position2
        if new_target2 <= 0 then
          wins2 = wins2 + multiplier1 * multiplier2
        else
          local next_wins1, next_wins2 = count_wins(new_position1, new_position2, new_target1, new_target2)
          wins1 = wins1 + next_wins1 * multiplier1 * multiplier2
          wins2 = wins2 + next_wins2 * multiplier1 * multiplier2
        end
      end
    end
  end

  memo[memo_key] = { wins1, wins2 }

  return wins1, wins2
end

print(math.max(count_wins(2, 7, 21, 21)))
