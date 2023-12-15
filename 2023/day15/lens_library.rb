require_relative "../common"

module LensLibrary
  MAX_HASH = 256

  class InitSequence
    attr_reader :operations

    def initialize(operations)
      @operations = operations
    end

    def checksum
      operations.sum(&:hash)
    end

    def run
      hashmap = HashMap.new
      operations.each { _1.run(hashmap) }
      hashmap.focusing_power
    end
  end

  class Operation
    def hash
      Hasher.hash(to_s)
    end
  end

  class InsertOperation < Operation
    attr_reader :label, :focal_length

    def initialize(label, focal_length)
      @label, @focal_length = label, focal_length
    end

    def to_s
      "#{label}=#{focal_length}"
    end

    def run(hashmap)
      hashmap.insert(label, focal_length)
    end
  end

  class DeleteOperation < Operation
    attr_reader :label

    def initialize(label)
      @label = label
    end

    def to_s
      "#{label}-"
    end

    def run(hashmap)
      hashmap.delete(label)
    end
  end

  class HashMap
    def initialize
      @boxes = (0...MAX_HASH).map { [] }
    end

    def insert(label, focal_length)
      box, idx = find_lens(label)
      box[idx || box.length] = Lens.new(label, focal_length)
    end

    def delete(label)
      box, idx = find_lens(label)
      box.delete_at(idx) if idx
    end

    def focusing_power
      @boxes.map.with_index do |box, box_index|
        box.map.with_index do |lens, slot_index|
          lens.focusing_power(box_index + 1, slot_index + 1)
        end.sum
      end.sum
    end

    private

    def find_lens(label)
      box = @boxes[Hasher.hash(label)]
      idx = box.index { |lens| lens.label == label }
      [box, idx]
    end
  end

  class Lens
    attr_reader :label, :focal_length

    def initialize(label, focal_length)
      @label, @focal_length = label, focal_length
    end

    def focusing_power(box_number, slot_number)
      box_number * slot_number * focal_length
    end
  end

  class Hasher
    def self.hash(string)
      string.chars.reduce(0) do |hash, char|
        ((hash + char.ord) * 17) % MAX_HASH
      end
    end
  end
end

class LensLibraryPuzzle < Puzzle
  include LensLibrary

  attr_reader :init_sequence

  def initialize(init_sequence)
    @init_sequence = init_sequence
  end

  def solve_part_one
    init_sequence.checksum
  end

  def solve_part_two
    init_sequence.run
  end

  def self.parse(input)
    operations = input.strip.split(',').map do |s|
      case s
      when /^(\w+)-$/
        DeleteOperation.new($1)
      when /^(\w+)=(\d+)$/
        InsertOperation.new($1, $2.to_i)
      else
        raise "invalid operation"
      end
    end

    new(InitSequence.new(operations))
  end
end

if test?
  class LensLibraryPuzzleTest < Minitest::Test
    include LensLibrary

    EXAMPLE_INPUT = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 1320, LensLibraryPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 505379, LensLibraryPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 145, LensLibraryPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 263211, LensLibraryPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
