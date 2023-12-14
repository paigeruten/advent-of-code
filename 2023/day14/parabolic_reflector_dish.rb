require_relative "../common"

module ParabolicReflectorDish
  class Platform
    attr_reader :tiles

    def initialize(tiles)
      @tiles = tiles
    end

    def to_s
      @tiles.map(&:join).join("\n")
    end

    def width
      @tiles.first.length
    end

    def height
      @tiles.length
    end

    def tilt_north!
      (0...width).each do |x|
        empty_space = nil
        (0...height).each do |y|
          case @tiles[y][x]
          when ?#
            # Rock cannot move into empty space above this.
            empty_space = nil
          when ?O
            if empty_space
              # Move rock into uppermost empty space.
              @tiles[empty_space.begin][x] = ?O
              @tiles[y][x] = ?.
              empty_space = (empty_space.begin + 1)..y
            end
          when ?.
            # Mark this as an empty space a rock can move to (or through).
            empty_space = (empty_space&.begin || y)..y
          end
        end
      end
      self
    end

    def spin_cycle!
      4.times do
        tilt_north!
        rotate_clockwise!
      end
    end

    def rotate_clockwise!
      @tiles = @tiles.transpose.map(&:reverse)
    end

    def long_spin_cycle(num_spins)
      platform = self.dup
      history = {}

      # Keep spin-cycling until a recurring cycle is detected.
      cycle_start, cycle_end = (0..).each do |step|
        history[platform.to_s] = { step:, platform: platform.dup }
        platform.spin_cycle!
        break history[platform.to_s][:step], step if history[platform.to_s]
      end

      # Figure out where in the cycle we'd land.
      cycle_length = cycle_end - cycle_start + 1
      final_step = cycle_start + (num_spins - cycle_start) % cycle_length

      # Return the state of the platform we'd land on.
      history.values.find { _1[:step] == final_step }[:platform]
    end

    def total_load
      @tiles.map.with_index do |row, idx|
        row.count(?O) * (height - idx)
      end.sum
    end

    def dup
      Platform.new(@tiles.dup.map(&:dup))
    end
  end
end

class ParabolicReflectorDishPuzzle < Puzzle
  include ParabolicReflectorDish

  attr_reader :platform

  def initialize(platform)
    @platform = platform
  end

  def solve_part_one
    platform.tilt_north!.total_load
  end

  def solve_part_two
    platform.long_spin_cycle(1_000_000_000).total_load
  end

  def self.parse(input)
    new(Platform.new(input.lines.map(&:chomp).map(&:chars)))
  end
end

if test?
  class ParabolicReflectorDishPuzzleTest < Minitest::Test
    include ParabolicReflectorDish

    EXAMPLE_INPUT = <<~EOF
      O....#....
      O.OO#....#
      .....##...
      OO.#O....O
      .O.....O#.
      O.#..O.#.#
      ..O..#O..O
      .......O..
      #....###..
      #OO..#....
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 136, ParabolicReflectorDishPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 108813, ParabolicReflectorDishPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 64, ParabolicReflectorDishPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 104533, ParabolicReflectorDishPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class PlatformTest < Minitest::Test
    include ParabolicReflectorDish

    def test_spin_cycle
      input = <<~EOF
        O....#....
        O.OO#....#
        .....##...
        OO.#O....O
        .O.....O#.
        O.#..O.#.#
        ..O..#O..O
        .......O..
        #....###..
        #OO..#....
      EOF
      platform = ParabolicReflectorDishPuzzle.parse(input).platform

      platform.spin_cycle!
      expected = <<~EOF
        .....#....
        ....#...O#
        ...OO##...
        .OO#......
        .....OOO#.
        .O#...O#.#
        ....O#....
        ......OOOO
        #...O###..
        #..OO#....
      EOF
      assert_equal expected.chomp, platform.to_s

      platform.spin_cycle!
      expected = <<~EOF
        .....#....
        ....#...O#
        .....##...
        ..O#......
        .....OOO#.
        .O#...O#.#
        ....O#...O
        .......OOO
        #..OO###..
        #.OOO#...O
      EOF
      assert_equal expected.chomp, platform.to_s

      platform.spin_cycle!
      expected = <<~EOF
        .....#....
        ....#...O#
        .....##...
        ..O#......
        .....OOO#.
        .O#...O#.#
        ....O#...O
        .......OOO
        #...O###.O
        #.OOO#...O
      EOF
      assert_equal expected.chomp, platform.to_s
    end
  end
end
