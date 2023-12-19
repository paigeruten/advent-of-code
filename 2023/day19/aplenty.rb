require_relative "../common"
require "paco"

module Aplenty
  class CombinatorialPartSorter
    def initialize(workflows)
      @workflows = workflows.map { [_1.label, _1] }.to_h
    end

    def num_accepted_combinations
      queue = [[:in, Part.new(x: 1..4000, m: 1..4000, a: 1..4000, s: 1..4000)]]
      accepted = []

      until queue.empty?
        label, part = queue.shift
        @workflows[label].process_ranged(part).each do |dest, subpart|
          case dest
          when :accepted
            accepted << subpart
          when :rejected
            # throw it away
          else
            queue << [dest, subpart]
          end
        end
      end

      accepted.sum(&:combinations)
    end
  end

  class PartSorter
    def initialize(workflows, parts)
      @workflows = workflows.map { [_1.label, _1] }.to_h
      @parts = parts
    end

    def accepted_parts
      @parts.select { bin(_1) == :accepted }
    end

    def bin(part)
      label = :in
      until [:accepted, :rejected].include? label
        label = @workflows[label].process(part)
      end
      label
    end
  end

  class Workflow
    attr_reader :label, :rules

    def initialize(label, rules)
      @label, @rules = label, rules
    end

    def process(part)
      rules.each do |rule|
        return rule.destination if rule.matches?(part)
      end
      raise "no matching rules in workflow #{label} for #{part.inspect}"
    end

    def process_ranged(part)
      matches = []
      remaining_part = part
      rules.each do |rule|
        destination, matched_part, remaining_part = rule.process_ranged(remaining_part)
        matches << [destination, matched_part] unless matched_part.nil?
        break if remaining_part.nil?
      end
      matches
    end
  end

  class Rule
    attr_reader :condition, :destination

    def initialize(condition, destination)
      @condition, @destination = condition, destination
    end

    def matches?(part)
      condition.nil? || condition.matches?(part)
    end

    def process_ranged(part)
      if condition.nil?
        [destination, part, nil]
      else
        t, f = condition.split_range(part)
        [destination, t, f]
      end
    end
  end

  class Condition
    def initialize(field, comparator, value)
      @field, @comparator, @value = field, comparator, value
    end

    def matches?(part)
      part.send(@field).send(@comparator, @value)
    end

    def split_range(part)
      range = part.send(@field)
      case @comparator
      when :<
        if range.end < @value
          [part, nil]
        elsif range.begin >= @value
          [nil, part]
        else
          part.split(@field, range.begin..(@value - 1), @value..range.end)
        end
      when :>
        if range.begin > @value
          [part, nil]
        elsif range.end <= @value
          [nil, part]
        else
          part.split(@field, (@value + 1)..range.end, range.begin..@value)
        end
      end
    end
  end

  class Part
    attr_reader :x, :m, :a, :s

    def initialize(x:, m:, a:, s:)
      @x, @m, @a, @s = x, m, a, s
    end

    def rating
      x + m + a + s
    end

    def combinations
      x.size * m.size * a.size * s.size
    end

    def split(field, left, right)
      [
        Part.new(**to_h.merge({field => left})),
        Part.new(**to_h.merge({field => right})),
      ]
    end

    def to_h
      {x:, m:, a:, s:}
    end
  end
end

class AplentyPuzzle < Puzzle
  attr_reader :part_sorter, :combinatorial_part_sorter

  def initialize(part_sorter, combinatorial_part_sorter)
    @part_sorter = part_sorter
    @combinatorial_part_sorter = combinatorial_part_sorter
  end

  def solve_part_one
    part_sorter.accepted_parts.sum(&:rating)
  end

  def solve_part_two
    combinatorial_part_sorter.num_accepted_combinations
  end

  class << self
    include Aplenty
    include Paco

    def parse(input)
      integer = digits.fmap(&:to_i)
      label = regexp(/[a-z]+/).fmap(&:to_sym)
      end_state = alt(string("A").result(:accepted), string("R").result(:rejected))
      field = one_of("xmas").fmap(&:to_sym)
      comparator = one_of("<>").fmap(&:to_sym)

      condition = seq(field, comparator, integer)
        .fmap { Condition.new(_1, _2, _3) }
      rule = seq(
        optional(condition.skip(string(":"))),
        alt(label, end_state)
      ).fmap { Rule.new(_1, _2) }
      workflow = seq(
        label,
        sep_by!(rule, string(",")).wrap(string("{"), string("}"))
      ).fmap { Workflow.new(_1, _2) }

      part = sep_by!(
        seq(field.skip(string("=")), integer),
        string(",")
      ).wrap(string("{"), string("}"))
        .fmap { |ratings| Part.new(**ratings.to_h) }

      workflows, parts = seq(
        sep_by!(workflow, ws).skip(ws),
        sep_by!(part, ws).skip(opt_ws)
      ).parse(input)

      new(
        PartSorter.new(workflows, parts),
        CombinatorialPartSorter.new(workflows)
      )
    end
  end
end

if test?
  class AplentyPuzzleTest < Minitest::Test
    include Aplenty

    EXAMPLE_INPUT = <<~EOF
      px{a<2006:qkq,m>2090:A,rfg}
      pv{a>1716:R,A}
      lnx{m>1548:A,A}
      rfg{s<537:gd,x>2440:R,A}
      qs{s>3448:A,lnx}
      qkq{x<1416:A,crn}
      crn{x>2662:A,R}
      in{s<1351:px,qqz}
      qqz{s>2770:qs,m<1801:hdj,R}
      gd{a>3333:R,R}
      hdj{m>838:A,pv}

      {x=787,m=2655,a=1222,s=2876}
      {x=1679,m=44,a=2067,s=496}
      {x=2036,m=264,a=79,s=2244}
      {x=2461,m=1339,a=466,s=291}
      {x=2127,m=1623,a=2188,s=1013}
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 19114, AplentyPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 434147, AplentyPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 167409079868000, AplentyPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 136146366355609, AplentyPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
