require_relative "../common"
require "paco"

module Scratchcards
  class ScratchcardSet
    include BasicEquality

    attr_reader :scratchcards

    def initialize(scratchcards)
      @scratchcards = scratchcards
    end

    def total_points
      scratchcards.sum(&:points)
    end

    def total_processed_cards
      card_counts = scratchcards.map { |card| [card.id, 1] }.to_h

      scratchcards.sort_by(&:id).each do |card|
        (card.id + 1).upto(card.id + card.number_of_matches).each do |card_id_won|
          card_counts[card_id_won] += card_counts[card.id]
        end
      end

      card_counts.values.sum
    end
  end

  class Scratchcard
    include BasicEquality

    attr_reader :id, :winning_numbers, :numbers_you_have

    def initialize(id, winning_numbers, numbers_you_have)
      @id, @winning_numbers, @numbers_you_have = id, winning_numbers, numbers_you_have
    end

    def points
      1 << (number_of_matches - 1)
    end

    def number_of_matches
      (winning_numbers & numbers_you_have).length
    end
  end
end

class ScratchcardsPuzzle < Puzzle
  attr_reader :scratchcard_set

  def initialize(scratchcard_set)
    @scratchcard_set = scratchcard_set
  end

  def solve_part_one
    scratchcard_set.total_points
  end

  def solve_part_two
    scratchcard_set.total_processed_cards
  end

  class << self
    include Scratchcards
    include Paco

    def parse(input)
      integer = digits.fmap(&:to_i)
      card_numbers = seq(
        integer.skip(ws).at_least(1).skip(spaced(string("|"))),
        integer.skip(ws).at_least(1)
      )
      scratchcard = seq(
        string("Card").next(ws).next(integer).skip(spaced(string(":"))),
        card_numbers
      )
        .fmap { |id, (winning_numbers, numbers_you_have)| Scratchcard.new(id, winning_numbers, numbers_you_have) }
      scratchcard_set = many(spaced(scratchcard))
        .fmap { |scratchcards| ScratchcardSet.new(scratchcards) }

      new(scratchcard_set.parse(input))
    end
  end
end

if test?
  class ScratchcardsPuzzleTest < Minitest::Test
    include Scratchcards

    EXAMPLE_INPUT = <<~EOF
      Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
      Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
      Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
      Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
      Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
      Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_parse
      input = <<~EOF
        Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
      EOF

      expected = ScratchcardSet.new([
        Scratchcard.new(1, [41, 48, 83, 86, 17], [83, 86, 6, 31, 17, 9, 48, 53]),
        Scratchcard.new(2, [13, 32, 20, 16, 61], [61, 30, 68, 82, 17, 32, 24, 19]),
      ])

      assert_equal expected, ScratchcardsPuzzle.parse(input).scratchcard_set
    end

    def test_example_input_part_one
      assert_equal 13, ScratchcardsPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 25183, ScratchcardsPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 30, ScratchcardsPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 5667240, ScratchcardsPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class ScratchcardTest < Minitest::Test
    include Scratchcards

    def test_points
      scratchcard = Scratchcard.new(1, [41, 48, 83, 86, 17], [83, 86, 6, 31, 17, 9, 48, 53])
      assert_equal 8, scratchcard.points
    end

    def test_points_zero
      scratchcard = Scratchcard.new(1, [31, 18, 13, 56, 72], [74, 77, 10, 23, 35, 67, 36, 11])
      assert_equal 0, scratchcard.points
    end
  end
end
