require_relative "../common"

module HotSprings
  class SpringRow
    @@memo = {}

    attr_reader :row, :pattern

    def initialize(row, pattern)
      @row, @pattern = row, pattern
    end

    def arrangements
      if pattern.empty?
        return row.include?("#") ? 0 : 1
      end

      # Just focus on where to place the first block. For each possible placement
      # (rejecting placements that overlap with a "." or connect to a "#"),
      # recurse on a problem that's one step smaller: how many ways can the
      # remaining blocks be placed after the first one has been placed?
      # (Memoizing the subproblems speeds this up a lot.)
      block_length = pattern[0]

      @@memo[[row, pattern]] ||= 0.upto(row.length - min_pattern_length)
        .reject { |i| row[0...i].include?("#") }
        .reject { |i| row[i + block_length] == "#" }
        .reject { |i| row[i...(i + block_length)].include?(".") }
        .sum    { |i| SpringRow.new(row[(i + block_length + 1)..] || "", pattern[1..]).arrangements }
    end

    def min_pattern_length
      pattern.sum + pattern.length - 1
    end

    def unfold
      SpringRow.new(([row] * 5).join("?"), pattern * 5)
    end
  end
end

class HotSpringsPuzzle < Puzzle
  include HotSprings

  attr_reader :spring_rows

  def initialize(spring_rows)
    @spring_rows = spring_rows
  end

  def solve_part_one
    spring_rows.sum(&:arrangements)
  end

  def solve_part_two
    spring_rows.map(&:unfold).sum(&:arrangements)
  end

  def self.parse(input)
    spring_rows = input.lines.map do |line|
      row, pattern_str = line.split
      pattern = pattern_str.split(",").map(&:to_i)
      SpringRow.new(row, pattern)
    end

    new(spring_rows)
  end
end

if test?
  class HotSpringsPuzzleTest < Minitest::Test
    include HotSprings

    EXAMPLE_INPUT = <<~EOF
      ???.### 1,1,3
      .??..??...?##. 1,1,3
      ?#?#?#?#?#?#?#? 1,3,1,6
      ????.#...#... 4,1,1
      ????.######..#####. 1,6,5
      ?###???????? 3,2,1
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 21, HotSpringsPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 7090, HotSpringsPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 525152, HotSpringsPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 6792010726878, HotSpringsPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class SpringRowTest < Minitest::Test
    include HotSprings

    def test_arrangements_1a
      assert_equal 1, SpringRow.new("???.###", [1, 1, 3]).arrangements
    end

    def test_arrangements_1b
      assert_equal 1, SpringRow.new("?#?#?#?#?#?#?#?", [1, 3, 1, 6]).arrangements
    end

    def test_arrangements_1c
      assert_equal 1, SpringRow.new("????.#...#...", [4, 1, 1]).arrangements
    end

    def test_arrangements_4a
      assert_equal 4, SpringRow.new(".??..??...?##.", [1, 1, 3]).arrangements
    end

    def test_arrangements_4b
      assert_equal 4, SpringRow.new("????.######..#####.", [1, 6, 5]).arrangements
    end

    def test_arrangements_10
      assert_equal 10, SpringRow.new("?###????????", [3, 2, 1]).arrangements
    end
  end
end
