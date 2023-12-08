dofile("../common.lua")

io.input("input")

local called_numbers = {}
for num in string.gmatch(io.read(), "%d+") do
  table.insert(called_numbers, tonumber(num))
end

local boards = {}
local numbers = {}
while true do
  local num = io.read("n")
  if not num then break end

  table.insert(numbers, num)
  if #numbers == 25 then
    table.insert(boards, { numbers = numbers, marked = {}, won = false, score = nil })
    numbers = {}
  end
end
assert(table.empty(numbers))

local function check_win(board)
  local mark = board.marked
  for row = 1, 5 do
    local idx = (row - 1) * 5 + 1
    if mark[idx] and mark[idx+1] and mark[idx+2] and mark[idx+3] and mark[idx+4] then
      return true
    end
  end
  for col = 1, 5 do
    if mark[col] and mark[col+5] and mark[col+10] and mark[col+15] and mark[col+20] then
      return true
    end
  end
  return false
end

local function calculate_score(board, final_number)
  local score = 0
  for i, number in ipairs(board.numbers) do
    if not board.marked[i] then
      score = score + number
    end
  end
  return score * final_number
end

local last_winning_board
for _, called_number in ipairs(called_numbers) do
  for _, board in ipairs(boards) do
    if not board.won then
      for i, number in ipairs(board.numbers) do
        if number == called_number then
          board.marked[i] = true
          if check_win(board) then
            board.won = true
            board.score = calculate_score(board, called_number)
            last_winning_board = board
          end
        end
      end
    end
  end
end

print(last_winning_board.score)
