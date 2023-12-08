require_relative "../common"

module CamelCards
  class Game
    include BasicEquality

    attr_reader :hands

    def initialize(hands)
      @hands = hands
    end

    def total_winnings
      hands
        .sort
        .map.with_index { |hand, rank| hand.bid * (rank + 1) }
        .sum
    end
  end

  class Hand
    include Comparable

    attr_reader :cards, :bid, :type

    def initialize(cards, bid)
      @cards, @bid = cards, bid
      calculate_type!
    end

    def self.from_string(cards_string, bid = 0)
      cards = cards_string.chars.map { Card.new(_1) }
      new(cards, bid)
    end

    def <=>(other)
      [self.type, self.cards, self.bid] <=> [other.type, other.cards, other.bid]
    end

    private

    def calculate_type!
      shape = cards.reject(&:joker?).map(&:type).tally.values.sort.reverse
      shape[0] = (shape[0] || 0) + cards.count(&:joker?)

      @type = HandType.new({
        [5]             => :five_of_a_kind,
        [4, 1]          => :four_of_a_kind,
        [3, 2]          => :full_house,
        [3, 1, 1]       => :three_of_a_kind,
        [2, 2, 1]       => :two_pair,
        [2, 1, 1, 1]    => :one_pair,
        [1, 1, 1, 1, 1] => :high_card,
      }[shape])
    end
  end

  class HandType
    TYPES = [
      :high_card,
      :one_pair,
      :two_pair,
      :three_of_a_kind,
      :full_house,
      :four_of_a_kind,
      :five_of_a_kind,
    ]
    ORDER = TYPES.map.with_index.to_h

    include Comparable

    attr_reader :type

    def initialize(type)
      raise "not a valid hand type" unless TYPES.include?(type)
      @type = type
    end

    def <=>(other)
      ORDER[self.type] <=> ORDER[other.type]
    end
  end

  class Card
    TYPES = %w(? 2 3 4 5 6 7 8 9 T J Q K A)
    ORDER = TYPES.map.with_index.to_h

    include Comparable

    attr_reader :type

    def initialize(type)
      raise "not a valid card type" unless TYPES.include?(type)
      @type = type
    end

    def <=>(other)
      ORDER[self.type] <=> ORDER[other.type]
    end

    def joker?
      type == ??
    end
  end
end

class CamelCardsPuzzle < Puzzle
  include CamelCards

  attr_reader :game, :joker_game

  def initialize(game, joker_game)
    @game, @joker_game = game, joker_game
  end

  def solve_part_one
    game.total_winnings
  end

  def solve_part_two
    joker_game.total_winnings
  end

  def self.parse(input)
    split_lines = input.lines.map(&:split)

    hands = split_lines
      .map { |hand, bid| Hand.from_string(hand, bid.to_i) }
    joker_hands = split_lines
      .map { |hand, bid| Hand.from_string(hand.tr(?J, ??), bid.to_i) }

    new(Game.new(hands), Game.new(joker_hands))
  end
end

if test?
  class CamelCardsPuzzleTest < Minitest::Test
    include CamelCards

    EXAMPLE_INPUT = <<~EOF
      32T3K 765
      T55J5 684
      KK677 28
      KTJJT 220
      QQQJA 483
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_parse
      input = <<~EOF
        3JJ3K 765
        T55J5 684
      EOF

      expected_game = Game.new([
        Hand.new([Card.new(?3), Card.new(?J), Card.new(?J), Card.new(?3), Card.new(?K)], 765),
        Hand.new([Card.new(?T), Card.new(?5), Card.new(?5), Card.new(?J), Card.new(?5)], 684),
      ])

      expected_joker_game = Game.new([
        Hand.new([Card.new(?3), Card.new(??), Card.new(??), Card.new(?3), Card.new(?K)], 765),
        Hand.new([Card.new(?T), Card.new(?5), Card.new(?5), Card.new(??), Card.new(?5)], 684),
      ])

      parsed = CamelCardsPuzzle.parse(input)

      assert_equal expected_game, parsed.game
      assert_equal expected_joker_game, parsed.joker_game
    end

    def test_example_input_part_one
      assert_equal 6440, CamelCardsPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 253910319, CamelCardsPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 5905, CamelCardsPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 254083736, CamelCardsPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class HandTest < Minitest::Test
    include CamelCards

    def test_comparable
      hands = [
        Hand.from_string("32T3K"),
        Hand.from_string("QQQJA"),
        Hand.from_string("T55J5"),
        Hand.from_string("KK677"),
        Hand.from_string("KTJJT"),
      ]

      expected = [
        Hand.from_string("32T3K"),
        Hand.from_string("KTJJT"),
        Hand.from_string("KK677"),
        Hand.from_string("T55J5"),
        Hand.from_string("QQQJA"),
      ]

      assert_equal expected, hands.shuffle.sort
    end

    def test_comparable_with_jokers
      hands = [
        Hand.from_string("32T3K"),
        Hand.from_string("QQQ?A"),
        Hand.from_string("T55?5"),
        Hand.from_string("KK677"),
        Hand.from_string("KT??T"),
      ]

      expected = [
        Hand.from_string("32T3K"),
        Hand.from_string("KK677"),
        Hand.from_string("T55?5"),
        Hand.from_string("QQQ?A"),
        Hand.from_string("KT??T"),
      ]

      assert_equal expected, hands.shuffle.sort
    end

    def test_five_of_a_kind
      assert_equal HandType.new(:five_of_a_kind), Hand.from_string("AAAAA").type
    end

    def test_four_of_a_kind
      assert_equal HandType.new(:four_of_a_kind), Hand.from_string("AA8AA").type
    end

    def test_full_house
      assert_equal HandType.new(:full_house), Hand.from_string("23332").type
    end

    def test_three_of_a_kind
      assert_equal HandType.new(:three_of_a_kind), Hand.from_string("TTT98").type
    end

    def test_two_pair
      assert_equal HandType.new(:two_pair), Hand.from_string("23432").type
    end

    def test_one_pair
      assert_equal HandType.new(:one_pair), Hand.from_string("A23A4").type
    end

    def test_high_card
      assert_equal HandType.new(:high_card), Hand.from_string("23456").type
    end

    def test_joker_five_of_a_kind
      assert_equal HandType.new(:five_of_a_kind), Hand.from_string("A?A?A").type
    end

    def test_all_jokers_five_of_a_kind
      assert_equal HandType.new(:five_of_a_kind), Hand.from_string("?????").type
    end

    def test_joker_four_of_a_kind
      assert_equal HandType.new(:four_of_a_kind), Hand.from_string("?A8??").type
    end

    def test_joker_full_house
      assert_equal HandType.new(:full_house), Hand.from_string("2332?").type
    end

    def test_joker_three_of_a_kind
      assert_equal HandType.new(:three_of_a_kind), Hand.from_string("?TT98").type
    end

    def test_joker_one_pair
      assert_equal HandType.new(:one_pair), Hand.from_string("A23?4").type
    end
  end

  class CardTest < Minitest::Test
    include CamelCards

    def test_comparable
      cards = Card::TYPES.map { Card.new(_1) }

      assert_equal cards, cards.shuffle.sort
    end
  end
end
