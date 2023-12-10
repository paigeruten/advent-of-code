require_relative "../common"

module PipeMaze
  class Grid
    attr_reader :tiles, :start

    def initialize(tiles)
      @tiles = tiles
      find_start!
      infer_start_pipe!
    end

    def enclosed_tiles
      pipe_loop_tiles = pipe_loop.map { |pos| [pos, self[pos]] }.to_h

      enclosed = []
      @tiles.each.with_index do |row, y|
        # Scan the row, keeping track of how many times we've crossed the pipe
        # loop. Whenever we hit a ground/junk tile, we know it's inside the pipe
        # loop if we've crossed the pipe loop an odd number of times.
        #
        # Thank you Wikipedia: https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm
        pipes_crossed = 0
        x = 0
        while x < row.length
          pipe_tile = pipe_loop_tiles[[x, y]]
          if pipe_tile
            if pipe_tile.vertical?
              pipes_crossed += 1
            elsif pipe_tile.corner?
              x += 1
              x += 1 until pipe_loop_tiles[[x, y]].corner?
              end_pipe_tile = pipe_loop_tiles[[x, y]]

              # Corners are an interesting edge case (corner case?). They always
              # come in pairs, possibly with any number of horizontal pipes
              # between the pair. If the pair points the same vertical direction
              # (like L--J or F--7), it counts as 2 pipe crossings (or 0,
              # depending on how you look at it). If they point different
              # vertical directions (like L--7 or F--J), then it only counts as
              # 1 pipe crossing.
              if pipe_tile.vertical_pipe_directions == end_pipe_tile.vertical_pipe_directions
                pipes_crossed += 2
              else
                pipes_crossed += 1
              end
            end
          elsif pipes_crossed.odd?
            enclosed << [x, y]
          end
          x += 1
        end
      end
      enclosed
    end

    def pipe_loop
      path = []
      pos = start
      begin
        last_pos = path.last
        path << pos
        pos = connected_neighbours(pos).find { _1 != last_pos }
      end until pos == start
      path
    end

    def connected_neighbours(pos)
      tile = self[pos]
      result = tile.pipe_directions.filter_map do |direction|
        next_pos = direction + pos
        next_tile = self[next_pos]
        next_pos if next_tile && next_tile.pipe_directions.include?(direction.reverse)
      end
    end

    def [](pos)
      x, y = pos
      Tile.new(@tiles[y][x]) if x >= 0 && y >= 0 && @tiles[y][x]
    end

    private

    def find_start!
      @start = @tiles.each.with_index do |row, y|
        x = row.index(?S)
        break [x, y] if x
      end
    end

    def infer_start_pipe!
      x, y = @start

      connections = %i(north west south east).select do |dir|
        dir = Direction.new(dir)
        neighbour = self[dir + [x, y]]
        neighbour && neighbour.pipe_directions.include?(dir.reverse)
      end

      @tiles[y][x] = case connections
      when [:north, :south] then ?|
      when [:west, :east] then ?-
      when [:north, :west] then ?J
      when [:north, :east] then ?L
      when [:west, :south] then ?7
      when [:south, :east] then ?F
      else
        raise "no possible pipe for start tile"
      end
    end
  end

  class Tile
    def initialize(char)
      @char = char
    end

    def vertical?
      @char == ?|
    end

    def corner?
      "LJ7F".include? @char
    end

    def pipe_directions
      ({
        ?| => %i(north south),
        ?- => %i(east west),
        ?L => %i(north east),
        ?J => %i(north west),
        ?7 => %i(south west),
        ?F => %i(south east),
      }[@char] || []).map { Direction.new(_1) }
    end

    def vertical_pipe_directions
      pipe_directions.select(&:vertical?)
    end
  end

  class Direction
    attr_reader :direction

    def initialize(direction)
      @direction = direction
    end

    def ==(other)
      self.direction == other.direction
    end

    def +(pos)
      x, y = pos
      dx, dy = delta
      [x + dx, y + dy]
    end

    def vertical?
      [:north, :south].include? @direction
    end

    def delta
      {
        north: [0, -1],
        west: [-1, 0],
        south: [0, 1],
        east: [1, 0],
      }[@direction]
    end

    def reverse
      Direction.new({
        north: :south,
        west: :east,
        south: :north,
        east: :west,
      }[@direction])
    end
  end
end

class PipeMazePuzzle < Puzzle
  include PipeMaze

  attr_reader :grid

  def initialize(grid)
    @grid = grid
  end

  def solve_part_one
    grid.pipe_loop.length / 2
  end

  def solve_part_two
    grid.enclosed_tiles.length
  end

  def self.parse(input)
    new(Grid.new(input.lines.map(&:chomp).map(&:chars)))
  end
end

if test?
  class PipeMazePuzzleTest < Minitest::Test
    include PipeMaze

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_first_example_input_part_one
      input = <<~EOF
        -L|F7
        7S-7|
        L|7||
        -L-J|
        L|-JF
      EOF

      assert_equal 4, PipeMazePuzzle.parse(input).solve_part_one
    end

    def test_second_example_input_part_one
      input = <<~EOF
        7-F7-
        .FJ|7
        SJLL7
        |F--J
        LJ.LJ
      EOF

      assert_equal 8, PipeMazePuzzle.parse(input).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 6649, PipeMazePuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_simple_example_input_part_two
      input = <<~EOF
        ...........
        .S-------7.
        .|F-----7|.
        .||.....||.
        .||.....||.
        .|L-7.F-J|.
        .|..|.|..|.
        .L--J.L--J.
        ...........
      EOF

      assert_equal 4, PipeMazePuzzle.parse(input).solve_part_two
    end

    def test_squeezed_example_input_part_two
      input = <<~EOF
        ..........
        .S------7.
        .|F----7|.
        .||....||.
        .||....||.
        .|L-7F-J|.
        .|..||..|.
        .L--JL--J.
        ..........
      EOF

      assert_equal 4, PipeMazePuzzle.parse(input).solve_part_two
    end

    def test_larger_example_input_part_two
      input = <<~EOF
        .F----7F7F7F7F-7....
        .|F--7||||||||FJ....
        .||.FJ||||||||L7....
        FJL7L7LJLJ||LJ.L-7..
        L--J.L7...LJS7F-7L7.
        ....F-J..F7FJ|L7L7L7
        ....L7.F7||L7|.L7L7|
        .....|FJLJ|FJ|F7|.LJ
        ....FJL-7.||.||||...
        ....L---J.LJ.LJLJ...
      EOF

      assert_equal 8, PipeMazePuzzle.parse(input).solve_part_two
    end

    def test_bits_of_junk_example_input_part_two
      input = <<~EOF
        FF7FSF7F7F7F7F7F---7
        L|LJ||||||||||||F--J
        FL-7LJLJ||||||LJL-77
        F--JF--7||LJLJ7F7FJ-
        L---JF-JLJ.||-FJLJJ7
        |F|F-JF---7F7-L7L|7|
        |FFJF7L7F-JF7|JL---7
        7-L-JL7||F7|L7F-7F7|
        L.L7LFJ|||||FJL7||LJ
        L7JLJL-JLJLJL--JLJ.L
      EOF

      assert_equal 10, PipeMazePuzzle.parse(input).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 601, PipeMazePuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
