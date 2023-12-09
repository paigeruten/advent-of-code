$:.unshift __dir__

require "common"

require "day01/trebuchet"
require "day02/cube_conundrum"
require "day03/gear_ratios"
require "day04/scratchcards"
require "day05/food_production"
require "day06/wait_for_it"
require "day07/camel_cards"
require "day08/haunted_wasteland"
require "day09/mirage_maintenance"

exit if test?

PUZZLES = {
  1 => TrebuchetPuzzle,
  2 => CubeConundrumPuzzle,
  3 => GearRatiosPuzzle,
  4 => ScratchcardsPuzzle,
  5 => FoodProductionPuzzle,
  6 => WaitForItPuzzle,
  7 => CamelCardsPuzzle,
  8 => HauntedWastelandPuzzle,
  9 => MirageMaintenancePuzzle,
}

if ARGV.empty?
  puts "Usage: ruby #{$0} <day number or 'all'>"
  exit 1
end

puzzles = if ARGV.first.downcase == "all"
  PUZZLES
else
  day = ARGV.first.to_i
  puzzle = PUZZLES[day]
  if puzzle.nil?
    puts "No puzzle found for day #{day}"
    exit 1
  end
  {day => puzzle}
end

total_time = 0
puzzles.each do |day, puzzle_class|
  input = File.read("day%02d/input" % day)
  puzzle = puzzle_class.parse(input)
  puts "\x1b[1mDay #{day} (#{puzzle_class.to_s.sub /Puzzle$/, ''})\x1b[m"
  {
    1 => profile { puzzle.solve_part_one },
    2 => profile { puzzle.solve_part_two },
  }.each do |part, (solution, timing)|
    puts "  Part #{part}: \x1b[1;32m#{solution}\x1b[m (\x1b[33m#{ms(timing)}\x1b[m)"
    total_time += timing
  end
  puts
end

puts "Total time: \x1b[33m#{ms(total_time)}\x1b[m"
