require_relative "../common"

module NeverTellMeTheOdds
  class Hailstorm
    def initialize(hailstones)
      @hailstones = hailstones
    end

    def future_intersections_2d_within(range)
      @hailstones.combination(2).count do |h1, h2|
        point = h1.future_intersection_point_2d(h2)
        point && point.all? { |v| range === v }
      end
    end
  end

  class Hailstone
    attr_reader :x, :y, :z, :vx, :vy, :vz

    def initialize(x, y, z, vx, vy, vz)
      @x, @y, @z, @vx, @vy, @vz = x, y, z, vx, vy, vz
    end

    def future_intersection_point_2d(other)
      m1, b1 = slope_2d, offset_2d
      m2, b2 = other.slope_2d, other.offset_2d

      return nil if m1 == m2

      ix = (b2 - b1) / (m1 - m2).to_f
      iy = m1 * ix + b1

      future_2d?(ix, iy) && other.future_2d?(ix, iy) ? [ix, iy] : nil
    end

    def slope_2d
      vy / vx.to_f
    end

    def offset_2d
      y - slope_2d * x
    end

    def future_2d?(px, py)
      ((vx > 0 && px >= x) || (vx < 0 && px <= x)) &&
      ((vy > 0 && py >= y) || (vy < 0 && py <= y))
    end
  end
end

class NeverTellMeTheOddsPuzzle < Puzzle
  include NeverTellMeTheOdds

  attr_accessor :hailstorm

  def initialize(hailstorm)
    @hailstorm = hailstorm
  end

  def solve_part_one
    hailstorm.future_intersections_2d_within(200_000_000_000_000..400_000_000_000_000)
  end

  def solve_part_two
  end

  def self.parse(input)
    hailstones = input.lines.map do |line|
      if line =~ /^(-?\d+),\s+(-?\d+),\s+(-?\d+)\s+@\s+(-?\d+),\s+(-?\d+),\s+(-?\d+)$/
        Hailstone.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i)
      else
        raise "invalid line '#{line}'"
      end
    end

    new(Hailstorm.new(hailstones))
  end
end

if test?
  class NeverTellMeTheOddsPuzzleTest < Minitest::Test
    include NeverTellMeTheOdds

    EXAMPLE_INPUT = <<~EOF
      19, 13, 30 @ -2,  1, -2
      18, 19, 22 @ -1, -1, -2
      20, 25, 34 @ -2, -2, -4
      12, 31, 28 @ -1, -2, -1
      20, 19, 15 @  1, -5, -3
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 2, NeverTellMeTheOddsPuzzle.parse(EXAMPLE_INPUT).hailstorm.future_intersections_2d_within(7..27)
    end

    def test_actual_input_part_one
      assert_equal 18651, NeverTellMeTheOddsPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      skip
      assert_equal ??, NeverTellMeTheOddsPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip
      assert_equal ??, NeverTellMeTheOddsPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end

    def test_future_intersection_point_2d
      h1 = Hailstone.new(19, 13, 30, -2, 1, -2)
      h2 = Hailstone.new(20, 25, 34, -2, -2, -4)

      x, y = h1.future_intersection_point_2d(h2)
      assert_in_delta 11.667, x
      assert_in_delta 16.667, y
    end

    def test_future_intersection_point_2d_b
      h1 = Hailstone.new(19, 13, 30, -2, 1, -2)
      h2 = Hailstone.new(18, 19, 22, -1, -1, -2)

      x, y = h1.future_intersection_point_2d(h2)
      assert_in_delta 14.333, x
      assert_in_delta 15.333, y
    end

    def test_future_intersection_point_2d_returns_nil_when_parallel
      h1 = Hailstone.new(18, 19, 22, -1, -1, -2)
      h2 = Hailstone.new(20, 25, 34, -2, -2, -4)

      assert_nil h1.future_intersection_point_2d(h2)
    end

    def test_future_intersection_point_2d_returns_nil_when_past_intersection_a
      h1 = Hailstone.new(19, 13, 30, -2, 1, -2)
      h2 = Hailstone.new(20, 19, 15, 1, -5, -3)

      assert_nil h1.future_intersection_point_2d(h2)
    end

    def test_future_intersection_point_2d_returns_nil_when_past_intersection_b
      h1 = Hailstone.new(20, 25, 34, -2, -2, -4)
      h2 = Hailstone.new(20, 19, 15, 1, -5, -3)

      assert_nil h1.future_intersection_point_2d(h2)
    end

    def test_future_intersection_point_2d_returns_nil_when_past_intersection_both
      h1 = Hailstone.new(18, 19, 22, -1, -1, -2)
      h2 = Hailstone.new(20, 19, 15, 1, -5, -3)

      assert_nil h1.future_intersection_point_2d(h2)
    end
  end
end
