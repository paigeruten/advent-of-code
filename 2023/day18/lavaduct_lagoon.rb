require_relative "../common"

module LavaductLagoon
  class Terrain
    def initialize(holes)
      @holes = holes

      xs = holes.keys.map { _1[0] }
      ys = holes.keys.map { _1[1] }
      @x_range = (xs.min)..(xs.max)
      @y_range = (ys.min)..(ys.max)
    end

    def self.from_dig_plan(dig_plan)
      x, y = 0, 0
      holes = {[x, y] => true}

      dig_plan.steps.each do |step|
        dx, dy = step.direction.delta
        step.distance.times do
          x += dx
          y += dy
          holes[[x, y]] = true
        end
      end

      Terrain.new(holes)
    end

    def lagoon_volume
      outer_x_range = (@x_range.begin - 1)..(@x_range.end + 1)
      outer_y_range = (@y_range.begin - 1)..(@y_range.end + 1)
      queue = [[outer_x_range.begin, outer_y_range.begin]]
      visited = queue.to_set

      until queue.empty?
        current = queue.shift
        ALL_DIRECTIONS.map(&:delta).each do |dx, dy|
          next_x, next_y = current[0] + dx, current[1] + dy

          in_bounds = outer_x_range.include?(next_x) && outer_y_range.include?(next_y)
          not_dug = !@holes[[next_x, next_y]]
          not_visited = !visited.include?([next_x, next_y])
          if in_bounds && not_dug && not_visited
            visited << [next_x, next_y]
            queue << [next_x, next_y]
          end
        end
      end

      width = outer_x_range.end - outer_x_range.begin + 1
      height = outer_y_range.end - outer_y_range.begin + 1

      (width * height) - visited.size
    end

    def to_s
      str = ""
      @y_range.each do |y|
        @x_range.each do |x|
          str << (@holes[[x, y]] ? "#" : ".")
        end
        str << "\n"
      end
      str
    end
  end

  class DigPlan
    attr_reader :steps

    def initialize(steps)
      @steps = steps
    end
  end

  class DigPlanStep
    attr_reader :direction, :distance, :colour

    def initialize(direction, distance, colour)
      @direction, @distance, @colour = direction, distance, colour
    end
  end

  class Direction
    attr_reader :delta

    def initialize(delta)
      @delta = delta
    end
  end

  UP = Direction.new([0, -1])
  DOWN = Direction.new([0, 1])
  LEFT = Direction.new([-1, 0])
  RIGHT = Direction.new([1, 0])

  ALL_DIRECTIONS = [UP, DOWN, LEFT, RIGHT]
end

class LavaductLagoonPuzzle < Puzzle
  include LavaductLagoon

  attr_reader :dig_plan

  def initialize(dig_plan)
    @dig_plan = dig_plan
  end

  def solve_part_one
    Terrain.from_dig_plan(dig_plan).lagoon_volume
  end

  def self.parse(input)
    steps = input.lines.map do |line|
      if line =~ /^([UDLR]) (\d+) \(#([0-9a-f]+)\)$/
        direction = { ?U => UP, ?D => DOWN, ?L => LEFT, ?R => RIGHT }[$1]
        DigPlanStep.new(direction, $2.to_i, $3)
      else
        raise "invalid step '#{line}'"
      end
    end

    new(DigPlan.new(steps))
  end
end

if test?
  class LavaductLagoonPuzzleTest < Minitest::Test
    include LavaductLagoon

    EXAMPLE_INPUT = <<~EOF
      R 6 (#70c710)
      D 5 (#0dc571)
      L 2 (#5713f0)
      D 2 (#d2c081)
      R 2 (#59c680)
      D 2 (#411b91)
      L 5 (#8ceee2)
      U 2 (#caa173)
      L 1 (#1b58a2)
      U 2 (#caa171)
      R 2 (#7807d2)
      U 3 (#a77fa3)
      L 2 (#015232)
      U 2 (#7a21e3)
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 62, LavaductLagoonPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 48652, LavaductLagoonPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      skip
      assert_equal ??, LavaductLagoonPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip
      assert_equal ??, LavaductLagoonPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
