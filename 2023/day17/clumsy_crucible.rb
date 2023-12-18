require_relative "../common"
require "pairing_heap"

module ClumsyCrucible
  class HeatLossMap
    X = 0
    Y = 1
    DIRECTION = 2
    STEPS = 3

    def initialize(tiles)
      @tiles = tiles
    end

    def width
      @tiles.first.length
    end

    def height
      @tiles.length
    end

    def minimum_heat_loss(min_steps: 1, max_steps: 3)
      initial_node = [0, 0, :e, 0]

      unvisited = (0...width).to_a.product(
        (0...height).to_a,
        [:n, :s, :e, :w],
        (1..max_steps).to_a
      ).to_set

      distance = Hash.new(Float::INFINITY)
      distance[initial_node] = 0

      queue = PairingHeap::MinPriorityQueue.new
      unvisited.each { |node| queue.push(node, distance[node]) }

      min_distance_to_target = Float::INFINITY
      current = initial_node
      while current
        neighbours(current, min_steps, max_steps).select { |node| unvisited.include? node }.each do |neighbour|
          current_distance = distance[current] + @tiles[neighbour[Y]][neighbour[X]]
          if current_distance < distance[neighbour]
            distance[neighbour] = current_distance
            queue.decrease_key(neighbour, current_distance)
          end

          if neighbour[X] == width - 1 && neighbour[Y] == height - 1 && neighbour[STEPS] >= min_steps
            min_distance_to_target = [min_distance_to_target, distance[neighbour]].min
          end
        end

        unvisited.delete(current)
        current = queue.pop
      end
      min_distance_to_target
    end

    def neighbours(node, min_steps, max_steps)
      only_straight = (1...min_steps).include?(node[STEPS])

      directions = only_straight ? [node[DIRECTION]] : {
        n: %i(n e w),
        e: %i(e n s),
        s: %i(s e w),
        w: %i(w n s),
      }[node[DIRECTION]]

      directions.filter_map do |direction|
        dx, dy = {
          n: [0, -1],
          e: [1, 0],
          s: [0, 1],
          w: [-1, 0],
        }[direction]

        x, y = node[X] + dx, node[Y] + dy
        steps = direction == node[DIRECTION] ? node[STEPS] + 1 : 1
        [x, y, direction, steps] if x >= 0 && y >= 0 && x < width && y < height && steps <= max_steps
      end
    end
  end
end

class ClumsyCruciblePuzzle < Puzzle
  include ClumsyCrucible

  attr_reader :heat_loss_map

  def initialize(heat_loss_map)
    @heat_loss_map = heat_loss_map
  end

  def solve_part_one
    heat_loss_map.minimum_heat_loss(max_steps: 3)
  end

  def solve_part_two
    heat_loss_map.minimum_heat_loss(min_steps: 4, max_steps: 10)
  end

  def self.parse(input)
    new(HeatLossMap.new(input.lines.map { _1.chomp.chars.map(&:to_i) }))
  end
end

if test?
  class ClumsyCruciblePuzzleTest < Minitest::Test
    include ClumsyCrucible

    EXAMPLE_INPUT = <<~EOF
      2413432311323
      3215453535623
      3255245654254
      3446585845452
      4546657867536
      1438598798454
      4457876987766
      3637877979653
      4654967986887
      4564679986453
      1224686865563
      2546548887735
      4322674655533
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 102, ClumsyCruciblePuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      skip('Too slow!')
      assert_equal 1256, ClumsyCruciblePuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 94, ClumsyCruciblePuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip('Too slow!')
      assert_equal 1382, ClumsyCruciblePuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
