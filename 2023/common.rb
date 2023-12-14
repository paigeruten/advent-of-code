require "logger"
$logger = Logger.new(STDOUT, level: ENV["LOG"] || :warn)

def test? = ENV["TEST"]
if test?
  require "minitest/autorun"
  require "minitest/pride"
end

class Puzzle
  def solve_part_one = "TODO"
  def solve_part_two = "TODO"

  def self.parse(input) = self.new
end

module BasicEquality
  def ==(other)
    self.class == other.class &&
    self.instance_variables.all? { |v| self.instance_variable_get(v) == other.instance_variable_get(v) }
  end
end

def profile(&block)
  starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = block.call
  ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  [result, ending - starting]
end

def format_time(seconds)
  if seconds >= 1
    "%.2f seconds" % seconds
  else
    "%.2fms" % (seconds * 1000)
  end
end
