require_relative "../common"
require "paco"

module FoodProduction
  class Almanac
    include BasicEquality

    attr_reader :farming_maps

    def initialize(farming_maps)
      @farming_maps = farming_maps
    end

    def seed_locations(seeds)
      farming_maps_by_source = farming_maps.map { [_1.source, _1] }.to_h

      source = :seed
      values = seeds
      until source == :location
        farming_map = farming_maps_by_source[source]
        values = values.map { farming_map[_1] }
        source = farming_map.destination
      end

      values
    end

    def ranged_seed_locations(seed_ranges)
      farming_maps_by_source = farming_maps.map { [_1.source, _1] }.to_h

      source = :seed
      ranges = seed_ranges
      until source == :location
        farming_map = farming_maps_by_source[source]
        ranges = ranges.flat_map { farming_map.map_range(_1) }
        source = farming_map.destination
      end

      ranges
    end
  end

  class FarmingMap
    include BasicEquality

    attr_reader :source, :destination, :range_maps

    def initialize(source, destination, range_maps)
      @source, @destination, @range_maps = source, destination, range_maps
    end

    def [](value)
      range_maps.map { |range_map| range_map[value] }.compact.first || value
    end

    def map_range(range)
      all_unmapped = [range]
      all_mapped = []
      range_maps.each do |range_map|
        i = 0
        while i < all_unmapped.length
          mapped, unmapped = range_map.map_range(all_unmapped[i])
          if mapped.empty?
            i += 1
          else
            all_unmapped.delete_at(i)
            all_mapped += mapped
            all_unmapped += unmapped
          end
        end
      end
      all_unmapped + all_mapped
    end
  end

  class RangeMap
    include BasicEquality

    attr_reader :source_range, :destination_start

    def initialize(source_range, destination_start)
      @source_range, @destination_start = source_range, destination_start
    end

    def [](value)
      destination_start + (value - source_range.begin) if source_range.include? value
    end

    def map_range(range)
      mapped, unmapped = [], []

      case [source_range.cover?(range.begin), source_range.cover?(range.end - 1)]
      when [false, false]
        if range.begin < source_range.begin && range.end >= source_range.end
          mapped << (self[source_range.begin]...(self[source_range.end - 1]) + 1)
          unmapped << (range.begin...source_range.begin)
          unmapped << (source_range.end...range.end)
        else
          unmapped << range
        end
      when [true, true]
        mapped << (self[range.begin]...(self[range.end - 1]) + 1)
      when [false, true]
        unmapped << (range.begin...source_range.begin)
        mapped << (self[source_range.begin]...(self[range.end - 1]) + 1)
      when [true, false]
        unmapped << (source_range.end...range.end)
        mapped << (self[range.begin]...(self[source_range.end - 1]) + 1)
      end

      [mapped, unmapped]
    end
  end
end

class FoodProductionPuzzle < Puzzle
  include FoodProduction

  attr_reader :seeds, :almanac

  def initialize(seeds, almanac)
    @seeds, @almanac = seeds, almanac
  end

  def solve_part_one
    almanac.seed_locations(seeds).min
  end

  def solve_part_two
    almanac.ranged_seed_locations(seed_ranges).map(&:begin).min
  end

  def seed_ranges
    seeds.each_slice(2).map { |start, length| start...(start + length) }
  end

  class << self
    include FoodProduction
    include Paco

    def parse(input)
      integer = digits.fmap(&:to_i)
      seeds = string("seeds:").skip(ws).next(sep_by!(integer, ws))
      range_map = seq(integer.skip(ws), integer.skip(ws), integer)
        .fmap { |dest, src, len| RangeMap.new(src...(src + len), dest) }
      farming_map = seq(
        letters.skip(string("-to-")),
        letters.skip(spaced(string("map:"))),
        sep_by!(range_map, ws)
      )
        .fmap { |src, dest, range_maps| FarmingMap.new(src.to_sym, dest.to_sym, range_maps) }
      seeds, farming_maps = seq(
        seeds.skip(end_of_line).skip(ws),
        sep_by!(farming_map, ws).skip(ws)
      ).parse(input)

      new(seeds, Almanac.new(farming_maps))
    end
  end
end

if test?
  class FoodProductionPuzzleTest < Minitest::Test
    include FoodProduction

    EXAMPLE_INPUT = <<~EOF
      seeds: 79 14 55 13

      seed-to-soil map:
      50 98 2
      52 50 48

      soil-to-fertilizer map:
      0 15 37
      37 52 2
      39 0 15

      fertilizer-to-water map:
      49 53 8
      0 11 42
      42 0 7
      57 7 4

      water-to-light map:
      88 18 7
      18 25 70

      light-to-temperature map:
      45 77 23
      81 45 19
      68 64 13

      temperature-to-humidity map:
      0 69 1
      1 0 69

      humidity-to-location map:
      60 56 37
      56 93 4
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_parse
      input = <<~EOF
        seeds: 79 14 55 13

        seed-to-soil map:
        50 98 2
        52 50 48

        water-to-light map:
        88 18 7
        18 25 70

        temperature-to-humidity map:
        0 69 1
        1 0 69
      EOF

      expected_seeds = [79, 14, 55, 13]

      expected_almanac = Almanac.new([
        FarmingMap.new(:seed, :soil, [
          RangeMap.new(98...100, 50),
          RangeMap.new(50...98, 52),
        ]),
        FarmingMap.new(:water, :light, [
          RangeMap.new(18...25, 88),
          RangeMap.new(25...95, 18),
        ]),
        FarmingMap.new(:temperature, :humidity, [
          RangeMap.new(69...70, 0),
          RangeMap.new(0...69, 1),
        ]),
      ])

      parsed = FoodProductionPuzzle.parse(input)

      assert_equal expected_seeds, parsed.seeds
      assert_equal expected_almanac, parsed.almanac
    end

    def test_example_input_part_one
      assert_equal 35, FoodProductionPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 525792406, FoodProductionPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 46, FoodProductionPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 79004094, FoodProductionPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class FarmingMapTest < Minitest::Test
    include FoodProduction

    def test_index
      farming_map = FarmingMap.new(:seed, :soil, [
        RangeMap.new(98...100, 50),
        RangeMap.new(50...98, 52),
      ])

      assert_equal 49, farming_map[49]
      assert_equal 52, farming_map[50]
      assert_equal 53, farming_map[51]
      assert_equal 54, farming_map[52]
      assert_equal 99, farming_map[97]
      assert_equal 50, farming_map[98]
      assert_equal 51, farming_map[99]
      assert_equal 100, farming_map[100]
      assert_equal 101, farming_map[101]
    end
  end

  class RangeMapTest < Minitest::Test
    include FoodProduction

    def test_index
      range_map = RangeMap.new(98...100, 50)

      assert_nil range_map[97]
      assert_equal 50, range_map[98]
      assert_equal 51, range_map[99]
      assert_nil range_map[100]
    end

    def test_map_range_no_overlap
      range_map = RangeMap.new(90...100, 50)
      assert_equal [[], [1...6]], range_map.map_range(1...6)
    end

    def test_map_range_all_overlap
      range_map = RangeMap.new(90...100, 50)
      assert_equal [[53...57], []], range_map.map_range(93...97)
    end

    def test_map_range_left_overlap
      range_map = RangeMap.new(90...100, 50)
      assert_equal [[50...51], [87...90]], range_map.map_range(87...91)
    end

    def test_map_range_right_overlap
      range_map = RangeMap.new(90...100, 50)
      assert_equal [[57...60], [100...105]], range_map.map_range(97...105)
    end

    def test_map_range_left_and_right_overlap
      range_map = RangeMap.new(90...100, 50)
      assert_equal [[50...60], [85...90, 100...105]], range_map.map_range(85...105)
    end
  end
end
