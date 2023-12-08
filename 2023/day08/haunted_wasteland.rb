require_relative "../common"
require "paco"

module HauntedWasteland
  class DesertMap
    include BasicEquality

    attr_reader :path, :network

    def initialize(path, network)
      @path, @network = path, network
    end

    def count_steps(from)
      node = network[from]
      path.circular.each.with_index do |direction, num_steps|
        return num_steps if node.end?
        node = network.step(node, direction)
      end
    end

    def count_ghost_steps
      network.start_nodes
        .map { |node| count_steps(node.name) }
        .reduce { |acc, n| n / acc.gcd(n) * acc }
    end
  end

  class Path
    include BasicEquality

    attr_reader :directions

    def initialize(directions)
      @directions = directions
    end

    def circular
      directions.cycle
    end
  end

  class Network
    include BasicEquality

    attr_reader :nodes

    def initialize(nodes)
      @nodes = nodes.map { [_1.name, _1] }.to_h
    end

    def [](name)
      nodes[name]
    end

    def start_nodes
      nodes.values.select(&:start?)
    end

    def step(node, direction)
      nodes[node[direction]]
    end
  end

  class Node
    include BasicEquality

    attr_reader :name, :left, :right

    def initialize(name, left, right)
      @name, @left, @right = name, left, right
    end

    def [](direction)
      {left:, right:}[direction]
    end

    def start?
      name.end_with? ?A
    end

    def end?
      name.end_with? ?Z
    end
  end
end

class HauntedWastelandPuzzle < Puzzle
  include HauntedWasteland

  attr_reader :desert_map

  def initialize(desert_map)
    @desert_map = desert_map
  end

  def solve_part_one
    desert_map.count_steps(:AAA)
  end

  def solve_part_two
    desert_map.count_ghost_steps
  end

  class << self
    include HauntedWasteland
    include Paco

    def parse(input)
      direction = alt(string("L").result(:left), string("R").result(:right))
      path = direction.at_least(1).fmap { Path.new(_1) }

      label = regexp(/[a-z0-9]+/i).fmap(&:to_sym)
      node = seq(
        label.skip(spaced(string("="))).skip(spaced(string("("))),
        label.skip(spaced(string(","))),
        label.skip(spaced(string(")")))
      ).fmap { Node.new(_1, _2, _3) }
      network = node.at_least(1).fmap { Network.new(_1) }

      desert_map = seq(
        path.skip(ws),
        network.skip(opt_ws)
      ).fmap { DesertMap.new(_1, _2) }

      new(desert_map.parse(input))
    end
  end
end

if test?
  class HauntedWastelandPuzzleTest < Minitest::Test
    include HauntedWasteland

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_parse
      input = <<~EOF
        LLR

        AAA = (BBB, BBB)
        BBB = (AAA, ZZZ)
        ZZZ = (ZZZ, ZZZ)
      EOF

      expected = DesertMap.new(
        Path.new([:left, :left, :right]),
        Network.new([
          Node.new(:AAA, :BBB, :BBB),
          Node.new(:BBB, :AAA, :ZZZ),
          Node.new(:ZZZ, :ZZZ, :ZZZ),
        ])
      )

      assert_equal expected, HauntedWastelandPuzzle.parse(input).desert_map
    end

    def test_example_input_part_one_first_example
      input = <<~EOF
        RL

        AAA = (BBB, CCC)
        BBB = (DDD, EEE)
        CCC = (ZZZ, GGG)
        DDD = (DDD, DDD)
        EEE = (EEE, EEE)
        GGG = (GGG, GGG)
        ZZZ = (ZZZ, ZZZ)
      EOF

      assert_equal 2, HauntedWastelandPuzzle.parse(input).solve_part_one
    end

    def test_example_input_part_one_second_example
      input = <<~EOF
        LLR

        AAA = (BBB, BBB)
        BBB = (AAA, ZZZ)
        ZZZ = (ZZZ, ZZZ)
      EOF

      assert_equal 6, HauntedWastelandPuzzle.parse(input).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 24253, HauntedWastelandPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      input = <<~EOF
        LR

        11A = (11B, XXX)
        11B = (XXX, 11Z)
        11Z = (11B, XXX)
        22A = (22B, XXX)
        22B = (22C, 22C)
        22C = (22Z, 22Z)
        22Z = (22B, 22B)
        XXX = (XXX, XXX)
      EOF

      assert_equal 6, HauntedWastelandPuzzle.parse(input).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 12357789728873, HauntedWastelandPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
