require_relative "../common"

module GearRatios
  class EngineSchematic
    NON_SYMBOLS = (?0..?9).to_a << ?.

    attr_reader :lines

    def initialize(lines)
      @lines = lines
    end

    def part_numbers
      engine_parts.flat_map(&:part_numbers)
    end

    def gear_ratios
      engine_parts.select(&:gear?).map(&:gear_ratio)
    end

    def engine_parts
      parts = {}
      lines.each.with_index do |line, y|
        line.to_enum(:scan, /\d+/).map { Regexp.last_match.offset(0) }.each do |from, to|
          (from...to).flat_map { |x| symbol_neighbours(x, y) }.uniq.each do |nx, ny|
            (parts[[nx, ny]] ||= EnginePart.new(lines[ny][nx]))
              .add_part_number!(line[from...to].to_i)
          end
        end
      end
      parts.values
    end

    def symbol_neighbours(x, y)
      neighbours(x, y).select { |nx, ny| symbol?(nx, ny) }
    end

    def neighbours(x, y)
      [-1, 0, 1].product([-1, 0, 1]).map { |dx, dy| [x + dx, y + dy] }
    end

    def symbol?(x, y)
      !out_of_bounds?(x, y) && !NON_SYMBOLS.include?(lines[y][x])
    end

    def out_of_bounds?(x, y)
      x < 0 || y < 0 || lines[y].nil? || lines[y][x].nil?
    end
  end

  class EnginePart
    attr_reader :symbol, :part_numbers

    def initialize(symbol, part_numbers = [])
      @symbol, @part_numbers = symbol, part_numbers
    end

    def add_part_number!(part_number)
      part_numbers << part_number
      part_numbers.uniq!
    end

    def gear?
      symbol == ?* && part_numbers.length == 2
    end

    def gear_ratio
      part_numbers.inject(:*)
    end
  end
end

class GearRatiosPuzzle < Puzzle
  include GearRatios

  attr_reader :engine_schematic

  def initialize(engine_schematic)
    @engine_schematic = engine_schematic
  end

  def solve_part_one
    engine_schematic.part_numbers.sum
  end

  def solve_part_two
    engine_schematic.gear_ratios.sum
  end

  def self.parse(input)
    lines = input.lines.map(&:chomp)
    new(EngineSchematic.new(lines))
  end
end

if test?
  class GearRatiosPuzzleTest < Minitest::Test
    EXAMPLE_INPUT = <<~EOF
      467..114..
      ...*......
      ..35..633.
      ......#...
      617*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 4361, GearRatiosPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 535078, GearRatiosPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 467835, GearRatiosPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 75312571, GearRatiosPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
