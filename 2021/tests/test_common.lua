dofile("common.lua")

return {
  table_is_empty = function()
    assert(is_true(table.empty({})))
  end,
  table_is_not_empty = function()
    assert(is_false(table.empty({42})))
  end,
  table_is_not_empty_even_with_false_key = function()
    assert(is_false(table.empty({[false] = false})))
  end,

  table_partition = function()
    local is_even = function(x) return x % 2 == 0 end
    local evens, odds = table.partition({1, 2, 3, 4, 5}, is_even)

    assert(table_equals({2, 4}, evens))
    assert(table_equals({1, 3, 5}, odds))
  end,

  table_map = function()
    assert(table_equals(
      {1, 4, 9, 16},
      table.map({1, 2, 3, 4}, function(x) return x * x end)
    ))
  end,

  table_reduce = function()
    assert(equals(
      24,
      table.reduce({1, 2, 3, 4}, function(a, b) return a * b end, 1)
    ))
  end,

  string_tsplit = function()
    assert(table_equals({"a", "b", "c"}, string.tsplit("a,b,c", ",")))
    assert(table_equals({"", "a", "", "b", "", "c", ""}, string.tsplit(",a,,b,,c,", ",")))
    assert(table_equals({"asdf", "jkl", "qwerty"}, string.tsplit("asdf   jkl\t\nqwerty")))
    assert(table_equals({"a", "s", "d", "f"}, string.tsplit("asdf", "")))
    assert(table_equals({"asdf"}, string.tsplit("asdf", ",")))
    assert(table_equals({}, string.tsplit("", ",")))
  end,

  string_scan = function()
    assert(table_equals({"a", "s", "d", "f", "f"}, string.scan(" a.#5s.09d*ff", "%a")))
    assert(table_equals({"how", "are", "you"}, string.scan("how are you?", "%w+")))
    assert(table_equals({}, string.scan("asdf", "%d")))
  end,

  string_chars = function()
    local chars = ""
    for char in string.chars("asdf") do
      chars = chars .. char
    end

    assert(equals("asdf", chars))
  end,

  string_join = function()
    assert(equals("asdf,qwerty,uiop", string.join({"asdf", "qwerty", "uiop"}, ",")))
    assert(equals("asdf", string.join({"asdf"}, ",")))
    assert(equals("abc", string.join({"a", "b", "c"})))
    assert(equals("", string.join({})))
  end,
}
