require_relative "../common"

module FloorIsLava
  class Contraption
    def initialize(tiles)
      @tiles = tiles
      @beam_history = {}
    end

    def [](position)
      position.nonnegative? && @tiles.dig(position.y, position.x)
    end

    def width
      @tiles.first.length
    end

    def height
      @tiles.length
    end

    def cast_beam_aux(beam, been = Set.new)
      #return Set[Loop.new(beam)] if been.include?(beam)
      return been if been.include?(beam)

      tile = self[beam.position]
      return Set[] if not tile

      been |= [beam]
      @beam_history[beam] ||= Array(tile.redirect_beam(beam)).map { cast_beam_aux(_1, been) }.inject(:|) | Set[beam.position]
    end

    def cast_beam(beam)
      cast_beam_aux(beam).length
      #resolve_beam_history_loops!
      #@beam_history[beam].length
    end

    def resolve_beam_history_loops!
      loop do
        looop = nil
        @beam_history.keys.each do |beam|
          looop = @beam_history[beam].find { _1.is_a? Loop }
          break if looop
        end
        break if looop.nil?

        beams_in_loop = @beam_history.keys.select { |beam| @beam_history[beam].include?(looop) }
        beams_in_loop_set = beams_in_loop.map(&:position).to_set
        pp beams_in_loop.length
        beams_in_loop.each do |beam|
          @beam_history[beam].delete(looop)
          @beam_history[beam] |= beams_in_loop_set
        end
      end
    end

    def simulate(initial_beam)
      beams = [initial_beam]
      beam_history = Set.new
      energized_tiles = Set.new

      until beams.empty?
        next_beams = []
        beams.each do |beam|
          next if beam_history.include? beam

          tile = self[beam.position]
          next if not tile

          energized_tiles << beam.position
          beam_history << beam

          next_beams += Array(tile.redirect_beam(beam))
        end
        beams = next_beams
      end

      energized_tiles.length
    end

    def simulate_all
      #all_possible_starting_beams.map { |beam| simulate(beam) }.max
      all_possible_starting_beams.map { |beam| cast_beam(beam) }.max
    end

    def all_possible_starting_beams
      (0...width).map  { |x| Beam.new(Position.new(x, 0),          Direction.down)  } +
      (0...width).map  { |x| Beam.new(Position.new(x, height - 1), Direction.up)    } +
      (0...height).map { |y| Beam.new(Position.new(0, y),          Direction.right) } +
      (0...height).map { |y| Beam.new(Position.new(width - 1, y),  Direction.left)  }
    end

    def ppp(beams)
      s = @tiles.map.with_index do |row, y|
        row.map.with_index do |tile, x|
          if beams.any? { |beam| beam.position.x == x && beam.position.y == y }
            "#"
          else
            tile.to_s
          end
        end.join
      end.join("\n") + "\n\n"
      puts s
    end
  end

  class Tile
  end

  class EmptySpace < Tile
    def redirect_beam(beam)
      beam.move_forward
    end

    def to_s
      "."
    end
  end

  class Splitter < Tile
    attr_reader :orientation

    def initialize(orientation)
      @orientation = orientation
    end

    def to_s
      orientation.to_s
    end

    def redirect_beam(beam)
      case orientation
      when :|
        if beam.direction.vertical?
          beam.move_forward
        else
          [
            beam.face(Direction.up).move_forward,
            beam.face(Direction.down).move_forward,
          ]
        end
      when :-
        if beam.direction.horizontal?
          beam.move_forward
        else
          [
            beam.face(Direction.left).move_forward,
            beam.face(Direction.right).move_forward,
          ]
        end
      end
    end
  end

  class Mirror < Tile
    attr_reader :orientation

    def initialize(orientation)
      @orientation = orientation
    end

    def to_s
      orientation.to_s
    end

    def redirect_beam(beam)
      new_direction = case orientation
      when :/
        {
          Direction.up => Direction.right,
          Direction.right => Direction.up,
          Direction.down => Direction.left,
          Direction.left => Direction.down,
        }[beam.direction]
      when :'\\'
        {
          Direction.up => Direction.left,
          Direction.right => Direction.down,
          Direction.down => Direction.right,
          Direction.left => Direction.up,
        }[beam.direction]
      end

      beam.face(new_direction).move_forward
    end
  end

  class Beam
    attr_reader :position, :direction

    def initialize(position, direction)
      @position, @direction = position, direction
    end

    def move_forward
      Beam.new(position.move(direction), direction)
    end

    def face(new_direction)
      Beam.new(position, new_direction)
    end

    def eql?(other)
      self.class == other.class &&
      position.eql?(other.position) &&
      direction.eql?(other.direction)
    end

    def hash
      [position, direction].hash
    end
  end

  class Loop
    attr_reader :beam

    def initialize(beam)
      @beam = beam
    end

    def eql?(other)
      self.class == other.class && beam.eql?(other.beam)
    end

    def hash
      beam.hash
    end
  end

  class Position
    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def nonnegative?
      x >= 0 && y >= 0
    end

    def move(direction)
      dx, dy = direction.delta
      Position.new(x + dx, y + dy)
    end

    def eql?(other)
      self.class == other.class && [x, y] == [other.x, other.y]
    end

    def hash
      [x, y].hash
    end
  end

  class Direction
    attr_reader :delta

    def initialize(delta)
      @delta = delta
    end

    def self.up = new([0, -1])
    def self.right = new([1, 0])
    def self.down = new([0, 1])
    def self.left = new([-1, 0])

    def vertical?
      delta[1] != 0
    end

    def horizontal?
      delta[0] != 0
    end

    def eql?(other)
      self.class == other.class && self.delta == other.delta
    end

    def hash
      delta.hash
    end
  end
end

class FloorIsLavaPuzzle < Puzzle
  include FloorIsLava

  attr_reader :contraption

  def initialize(contraption)
    @contraption = contraption
  end

  def solve_part_one
    initial_beam = Beam.new(Position.new(0, 0), Direction.right)
    #contraption.simulate(initial_beam)

    contraption.cast_beam(initial_beam)
  end

  def solve_part_two
    contraption.simulate_all
  end

  def self.parse(input)
    tiles = input.lines.map(&:chomp).map do |line|
      line.chars.map do |char|
        case char
        when "."
          EmptySpace.new
        when "|", "-"
          Splitter.new(char.to_sym)
        when "/", "\\"
          Mirror.new(char.to_sym)
        else
          raise "unexpected char #{char.inspect}"
        end
      end
    end

    new(Contraption.new(tiles))
  end
end

if test?
  class FloorIsLavaPuzzleTest < Minitest::Test
    include FloorIsLava

    EXAMPLE_INPUT = <<~EOF
      .|...\\....
      |.-.\\.....
      .....|-...
      ........|.
      ..........
      .........\\
      ..../.\\\\..
      .-.-/..|..
      .|....-|.\\
      ..//.|....
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 46, FloorIsLavaPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 7562, FloorIsLavaPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 51, FloorIsLavaPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip
      assert_equal 7793, FloorIsLavaPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
