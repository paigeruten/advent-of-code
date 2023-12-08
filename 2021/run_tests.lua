local test_files = { "test_common.lua" }

function equals(expected, actual)
  return expected == actual, string.format(
    "Expected value does not match actual\nExpected: %s\nActual: %s",
    type(expected) == "string" and string.format("%q", expected) or tostring(expected),
    type(actual) == "string" and string.format("%q", actual) or tostring(actual)
  )
end

function table_equals(expected, actual)
  if type(expected) ~= "table" then
    return false, "Expected value must be a table"
  end
  if type(actual) ~= "table" then
    return false, "Expected a table, got a " .. type(actual)
  end

  local are_equal = true
  for k, v in pairs(expected) do
    if type(v) == "table" and actual[k] == "table" then
      if not table_equals(v, actual[k]) then
        are_equal = false
        break
      end
    elseif actual[k] ~= v then
      are_equal = false
      break
    end
  end
  if are_equal then
    for k, v in pairs(actual) do
      if type(v) == "table" and expected[k] == "table" then
        if not table_equals(v, expected[k]) then
          are_equal = false
          break
        end
      elseif expected[k] ~= v then
        are_equal = false
        break
      end
    end
  end

  if are_equal then return true end
  
  return false, string.format(
    "Expected table does not match actual table\nExpected: %s\nActual: %s",
    table.empty(expected) and "{}" or table.inspect(expected),
    table.empty(actual) and "{}" or table.inspect(actual)
  )
end

function is_true(actual)
  return equals(true, actual)
end

function is_false(actual)
  return equals(false, actual)
end

local failures = {}
for _, file in ipairs(test_files) do
  local tests = dofile("tests/" .. file)
  for test, testfunc in pairs(tests) do
    local status, err = pcall(testfunc)
    if status then
      io.write(".")
    else
      io.write("F")
      table.insert(failures, { file = file, test = test, err = err })
    end
  end
end

io.write("\n\n")

if #failures == 0 then
  io.write("All tests passed!\n")
else
  io.write(#failures == 1 and "1 test failed:\n\n" or #failures .. " tests failed:\n\n")

  for i, failure in ipairs(failures) do
    io.write("  " .. i .. ") " .. failure.file .. ":" .. failure.test .. "\n")
    io.write("  " .. string.gsub(failure.err, "\n", "\n  ") .. "\n\n")
  end
end

