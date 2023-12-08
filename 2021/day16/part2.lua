dofile("../common.lua")

io.input("input")
local input = io.read("l")

local TYPE_IDS <const> = {
  SUM = 0,
  PRODUCT = 1,
  MINIMUM = 2,
  MAXIMUM = 3,
  LITERAL = 4,
  GREATER_THAN = 5,
  LESS_THAN = 6,
  EQUAL_TO = 7,
}

local function hexchar2binary(char)
  local value = tonumber(char, 16)
  return (value & 8 == 0 and "0" or "1")
      .. (value & 4 == 0 and "0" or "1")
      .. (value & 2 == 0 and "0" or "1")
      .. (value & 1 == 0 and "0" or "1")
end

local binary = string.gsub(input, "%x", hexchar2binary)

local function read_packet(binary)
  local packet = {}

  local i = 1

  packet.version = tonumber(string.sub(binary, i, i + 2), 2)
  i = i + 3

  packet.type_id = tonumber(string.sub(binary, i, i + 2), 2)
  i = i + 3

  if packet.type_id == TYPE_IDS.LITERAL then
    local literal_bits = ""
    repeat
      local prefix_bit = string.sub(binary, i, i)
      i = i + 1

      literal_bits = literal_bits .. string.sub(binary, i, i + 3)
      i = i + 4
    until prefix_bit == "0"
    packet.literal = tonumber(literal_bits, 2)
  else
    local length_type_id = tonumber(string.sub(binary, i, i), 2)
    i = i + 1

    packet.subpackets = {}
    if length_type_id == 0 then
      local length_in_bits = tonumber(string.sub(binary, i, i + 14), 2)
      i = i + 15

      local total_bits_consumed = 0
      repeat
        local subpacket, bits_consumed = read_packet(string.sub(binary, i))
        i = i + bits_consumed
        total_bits_consumed = total_bits_consumed + bits_consumed

        table.insert(packet.subpackets, subpacket)
      until total_bits_consumed >= length_in_bits
    else
      local num_subpackets = tonumber(string.sub(binary, i, i + 10), 2)
      i = i + 11

      for _ = 1, num_subpackets do
        local subpacket, bits_consumed = read_packet(string.sub(binary, i))
        i = i + bits_consumed

        table.insert(packet.subpackets, subpacket)
      end
    end
  end

  local bits_consumed = i - 1

  return packet, bits_consumed
end

local packet, bits_consumed = read_packet(binary)

local function evaluate(packet)
  if packet.type_id == TYPE_IDS.LITERAL then
    return packet.literal
  end

  local operands = table.map(packet.subpackets, evaluate)
  if packet.type_id == TYPE_IDS.SUM then
    return table.reduce(operands, function (a, b) return a + b end, 0)
  elseif packet.type_id == TYPE_IDS.PRODUCT then
    return table.reduce(operands, function (a, b) return a * b end, 1)
  elseif packet.type_id == TYPE_IDS.MINIMUM then
    return math.min(table.unpack(operands))
  elseif packet.type_id == TYPE_IDS.MAXIMUM then
    return math.max(table.unpack(operands))
  elseif packet.type_id == TYPE_IDS.GREATER_THAN then
    return operands[1] > operands[2] and 1 or 0
  elseif packet.type_id == TYPE_IDS.LESS_THAN then
    return operands[1] < operands[2] and 1 or 0
  elseif packet.type_id == TYPE_IDS.EQUAL_TO then
    return operands[1] == operands[2] and 1 or 0
  else
    error("unexpected type_id " .. packet.type_id)
  end
end

print(evaluate(packet))
