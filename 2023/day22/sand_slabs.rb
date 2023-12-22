require_relative "../common"

module SandSlabs
  module Refinements
    refine Range do
      def overlaps?(other)
        cover?(other.first) || other.cover?(first)
      end
    end
  end

  class Well
    def initialize(bricks)
      @bricks_by_min_z = bricks.group_by(&:min_z)
      @bricks_by_max_z = bricks.group_by(&:max_z)
    end

    def bricks
      @bricks_by_max_z.values.flatten(1)
    end

    def bricks_sitting_on(z)
      @bricks_by_min_z[z] || []
    end

    def bricks_reaching_to(z)
      @bricks_by_max_z[z] || []
    end

    def drop_bricks!
      sorted_bricks = bricks.sort_by(&:min_z)
      sorted_bricks.each.with_index do |brick, idx|
        @bricks_by_min_z[brick.min_z].delete(brick)
        @bricks_by_max_z[brick.max_z].delete(brick)

        brick.move_down! until brick.min_z == 0 || bricks_reaching_to(brick.min_z).any? { _1.collides_with?(brick) }
        brick.move_up!

        (@bricks_by_min_z[brick.min_z] ||= []) << brick
        (@bricks_by_max_z[brick.max_z] ||= []) << brick
      end
    end

    def count_disintegratable_bricks
      bricks.count { |brick| supported_bricks(brick).empty? }
    end

    def supported_bricks(brick)
      other_bricks = bricks_reaching_to(brick.max_z) - [brick]
      bricks_sitting_on(brick.max_z + 1).select do |brick_above|
        moved_brick = brick_above.dup.move_down!
        moved_brick.collides_with?(brick) && !other_bricks.any? { moved_brick.collides_with?(_1) }
      end
    end

    # TODO: This doesn't work. If A supports B and C, and B and C both support,
    # D, and D supports all the rest of the bricks, then this will only count 2
    # falling bricks when disintegrating A. Maybe a data structure that tells us
    # which bricks each brick supports would help?
    def count_bricks_that_would_fall
      num_falling_bricks = {}

      sorted_bricks = @bricks_by_max_z.to_a.sort_by(&:first).map(&:last).reverse.flatten(1)
      sorted_bricks.each do |brick|
        num_falling_bricks[brick] ||= supported_bricks(brick).sum { 1 + num_falling_bricks[_1] }
      end

      num_falling_bricks.values.sum
    end
  end

  class Brick
    using Refinements

    attr_reader :start_point, :end_point

    def initialize(start_point, end_point)
      @start_point, @end_point = start_point, end_point
    end

    def max_z
      z_range.end
    end

    def min_z
      z_range.begin
    end

    def move_down!
      @start_point.z -= 1
      @end_point.z -= 1
      self
    end

    def move_up!
      @start_point.z += 1
      @end_point.z += 1
      self
    end

    def collides_with?(other)
      x_range.overlaps?(other.x_range) &&
      y_range.overlaps?(other.y_range) &&
      z_range.overlaps?(other.z_range)
    end

    def x_range
      xs = [@start_point.x, @end_point.x].sort
      xs[0]..xs[1]
    end

    def y_range
      ys = [@start_point.y, @end_point.y].sort
      ys[0]..ys[1]
    end

    def z_range
      zs = [@start_point.z, @end_point.z].sort
      zs[0]..zs[1]
    end

    def eql?(other)
      [start_point, end_point] == [other.start_point, other.end_point]
    end

    def hash
      [start_point, end_point].hash
    end

    def dup
      Brick.new(@start_point.dup, @end_point.dup)
    end
  end

  class Point
    attr_accessor :x, :y, :z

    def initialize(x, y, z)
      @x, @y, @z = x, y, z
    end

    def eql?(other)
      [x, y, z] == [other.x, other.y, other.z]
    end

    def hash
      [x, y, z].hash
    end

    def dup
      Point.new(x, y, z)
    end
  end
end

class SandSlabsPuzzle < Puzzle
  include SandSlabs

  attr_reader :well

  def initialize(well)
    @well = well
  end

  def solve_part_one
    well.drop_bricks!
    well.count_disintegratable_bricks
  end

  def solve_part_two
    well.drop_bricks!
    well.count_bricks_that_would_fall
  end

  def self.parse(input)
    bricks = input.lines.map do |line|
      if line =~ /^(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)$/
        Brick.new(Point.new($1.to_i, $2.to_i, $3.to_i), Point.new($4.to_i, $5.to_i, $6.to_i))
      else
        raise "invalid line '#{line}'"
      end
    end

    new(Well.new(bricks))
  end
end

if test?
  class SandSlabsPuzzleTest < Minitest::Test
    include SandSlabs

    EXAMPLE_INPUT = <<~EOF
      1,0,1~1,2,1
      0,0,2~2,0,2
      0,2,3~2,2,3
      0,0,4~0,2,4
      2,0,5~2,2,5
      0,1,6~2,1,6
      1,1,8~1,1,9
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 5, SandSlabsPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 530, SandSlabsPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      skip("Current solution attempt doesn't work")
      assert_equal 7, SandSlabsPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip
      assert_equal ??, SandSlabsPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
