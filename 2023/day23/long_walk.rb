require_relative "../common"

module LongWalk
  class HikingMap
    def initialize(tiles)
      @tiles = tiles
    end

    def to_graph(directed:)
      nodes_by_pos = {}

      start_node = Node.new(@tiles[0].index("."), 0)
      nodes_by_pos[start_node.pos] = start_node

      end_node = Node.new(@tiles[-1].index("."), @tiles.length - 1)
      nodes_by_pos[end_node.pos] = end_node

      queue = [[start_node, Direction.new(:south)]]

      until queue.empty?
        source_node, source_dir = queue.pop
        next if source_node.send(source_dir.to_sym) # already walked this trail?

        x, y = source_node.x, source_node.y
        dir = source_dir
        steps = 0
        encountered_hill = false
        loop do
          dx, dy = dir.delta
          x += dx
          y += dy
          encountered_hill = true if Direction.from_hill(@tiles[y][x])

          steps += 1
          neighbours = open_neighbours(x, y, except: dir.reverse, directed:)

          # More than one neighbour means we've reached our destination node
          if neighbours.length >= 2 || [x, y] == end_node.pos
            destination_node = (nodes_by_pos[[x, y]] ||= Node.new(x, y))

            source_node.add_trail!(source_dir, Trail.new(destination_node, steps))
            unless directed && encountered_hill
              destination_node.add_trail!(dir.reverse, Trail.new(source_node, steps))
            end

            neighbours.each do |neighbour|
              queue.unshift([destination_node, neighbour])
            end

            break
          elsif neighbours.length == 1
            # We're still in the "hallway" and need to continue stepping through it
            dir = neighbours.first
          elsif neighbours.empty?
            # Ran into a hill the wrong way
            break
          end
        end
      end

      HikingGraph.new(start_node, end_node)
    end

    private

    def open_neighbours(x, y, except:, directed:)
      hill = directed && Direction.from_hill(@tiles[y][x])
      (hill ? [hill] : DIRECTIONS).map do |dir|
        dx, dy = dir.delta
        nx, ny = x + dx, y + dy
        dir if dir.to_sym != except.to_sym && nx >= 0 && ny >= 0 && %w(. < > ^ v).include?(@tiles.dig(ny, nx))
      end.compact
    end
  end

  class Direction
    def initialize(sym)
      @sym = sym
    end

    def to_sym
      @sym
    end

    def delta
      case @sym
      when :north then [0, -1]
      when :east then [1, 0]
      when :south then [0, 1]
      when :west then [-1, 0]
      end
    end

    def reverse
      case @sym
      when :north then Direction.new(:south)
      when :east then Direction.new(:west)
      when :south then Direction.new(:north)
      when :west then Direction.new(:east)
      end
    end

    def self.from_hill(char)
      case char
      when "<" then Direction.new(:west)
      when ">" then Direction.new(:east)
      when "^" then Direction.new(:north)
      when "v" then Direction.new(:south)
      end
    end
  end

  DIRECTIONS = [
    Direction.new(:north),
    Direction.new(:east),
    Direction.new(:south),
    Direction.new(:west),
  ]

  class HikingGraph
    def initialize(start_node, end_node)
      @start_node, @end_node = start_node, end_node
    end

    def longest_hike
      hikes = [Hike.new(@start_node)]
      finished_hikes = []
      until hikes.empty?
        next_hikes = []
        hikes.each do |hike|
          untaken_trails = hike.node.trails.reject { |trail| hike.visited_node?(trail.destination) }
          if untaken_trails.empty?
            finished_hikes << hike if hike.node == @end_node
            next
          end
          untaken_trails[1..].each do |trail|
            forked_hike = hike.dup
            forked_hike.take_trail!(trail)
            next_hikes << forked_hike
          end
          hike.take_trail!(untaken_trails.first)
          next_hikes << hike
        end
        hikes = next_hikes
      end

      finished_hikes.max_by(&:length)
    end
  end

  class Node
    attr_accessor :x, :y, :north, :east, :south, :west

    def initialize(x, y)
      @x, @y = x, y
    end

    def pos
      [x, y]
    end

    def add_trail!(dir, trail)
      send("#{dir.to_sym}=", trail)
    end

    def trails
      [north, east, south, west].compact
    end
  end

  class Trail
    attr_accessor :destination, :length

    def initialize(destination, length)
      @destination, @length = destination, length
    end
  end

  class Hike
    def initialize(start_node, trails = [])
      @start_node = start_node
      @trails = trails
      @visited = Set.new.compare_by_identity
      @visited << start_node
      trails.each { |trail| @visited << trail.destination }
    end

    def length
      @trails.sum(&:length)
    end

    def node
      @trails.last&.destination || @start_node
    end

    def take_trail!(trail)
      @trails << trail
      @visited << trail.destination
    end

    def visited_node?(node)
      @visited.include?(node)
    end

    def dup
      Hike.new(@start_node, @trails.dup)
    end
  end
end

class LongWalkPuzzle < Puzzle
  include LongWalk

  attr_accessor :hiking_map

  def initialize(hiking_map)
    @hiking_map = hiking_map
  end

  def solve_part_one
    hiking_map.to_graph(directed: true).longest_hike.length
  end

  def solve_part_two
    hiking_map.to_graph(directed: false).longest_hike.length
  end

  def self.parse(input)
    tiles = input.lines.map(&:chomp).map(&:chars)

    new(HikingMap.new(tiles))
  end
end

if test?
  class LongWalkPuzzleTest < Minitest::Test
    include LongWalk

    EXAMPLE_INPUT = <<~EOF
      #.#####################
      #.......#########...###
      #######.#########.#.###
      ###.....#.>.>.###.#.###
      ###v#####.#v#.###.#.###
      ###.>...#.#.#.....#...#
      ###v###.#.#.#########.#
      ###...#.#.#.......#...#
      #####.#.#.#######.#.###
      #.....#.#.#.......#...#
      #.#####.#.#.#########v#
      #.#...#...#...###...>.#
      #.#.#v#######v###.###v#
      #...#.>.#...>.>.#.###.#
      #####v#.#.###v#.#.###.#
      #.....#...#...#.#.#...#
      #.#########.###.#.#.###
      #...###...#...#...#.###
      ###.###.#.###v#####v###
      #...#...#.#.>.>.#.>.###
      #.###.###.#.###.#.#v###
      #.....###...###...#...#
      #####################.#
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 94, LongWalkPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 2178, LongWalkPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 154, LongWalkPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip("Way too slow")
      assert_equal 6486, LongWalkPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
