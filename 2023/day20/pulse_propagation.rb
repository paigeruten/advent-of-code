require_relative "../common"

module PulsePropagation
  class Machine
    attr_reader :button_presses, :high_pulses, :low_pulses, :rx_low_pulses

    def initialize(mods)
      @mods = mods.map { [_1.name, _1] }.to_h
      connect_modules!

      @button_presses = 0
      @high_pulses = 0
      @low_pulses = 0
      @rx_low_pulses = 0
    end

    def push_button!
      @button_presses += 1
      queue = [[:button, :broadcaster, LOW]]

      until queue.empty?
        from, to, pulse = queue.shift
        mod = @mods[to]

        if pulse.high?
          @high_pulses += 1
        else
          @low_pulses += 1
          @rx_low_pulses += 1 if to == :rx
        end

        next if mod.nil?

        output_pulse = mod.send_pulse(pulse, from)
        if output_pulse
          queue += mod.destinations.map { |name| [to, name, output_pulse] }
        end
      end
    end

    def split
      @mods[:broadcaster].destinations.map do |start|
        submachine_mods = reachable_mods(start).map { @mods[_1].reset }
        submachine_mods << Broadcast.new(:broadcaster, [start])
        Machine.new(submachine_mods)
      end
    end

    def reachable_mods(from)
      visited = Set.new
      queue = [from]
      until queue.empty?
        name = queue.shift
        visited << name
        (@mods[name]&.destinations || []).each do |dest|
          queue << dest unless visited.include?(dest) || !@mods[dest]
        end
      end
      visited.to_a
    end

    def to_s
      @mods.values.join("\n") + "\n"
    end

    def to_mermaid
      "stateDiagram-v2\n    " +
      @mods.values.map { |mod| "state \"#{mod.symbol}#{mod.name}\" as #{mod.name}" }.join("\n    ") + "\n    " +
      @mods.flat_map do |name, mod|
        mod.destinations.map do |dest|
          "#{name} --> #{dest}"
        end
      end.join("\n    ") + "\n"
    end

    private

    def connect_modules!
      @mods.each do |name, mod|
        mod.destinations.each do |dest|
          @mods[dest].add_input!(name) if @mods[dest]
        end
      end
    end
  end

  class Mod
    attr_reader :name, :destinations
    attr_writer :destinations

    def initialize(name, destinations)
      @name, @destinations = name, destinations
    end

    def symbol
      ""
    end

    def add_input!(input)
    end

    def send_pulse(pulse, from = nil)
    end

    def reset
      self.class.new(name, destinations)
    end
  end

  class FlipFlop < Mod
    def initialize(name, destinations)
      super
      @is_on = false
    end

    def symbol
      "%"
    end

    def send_pulse(pulse, from = nil)
      if pulse.low?
        @is_on = !@is_on
        @is_on ? HIGH : LOW
      end
    end

    def to_s
      "[#{@is_on ? 'ON ' : 'OFF'}] %#{name} -> #{destinations.join(', ')}"
    end
  end

  class Conjunction < Mod
    def initialize(name, destinations)
      super
      @inputs = {}
    end

    def symbol
      "&"
    end

    def add_input!(input)
      @inputs[input] = LOW
    end

    def send_pulse(pulse, from)
      @inputs[from] = pulse
      @inputs.values.all?(&:high?) ? LOW : HIGH
    end

    def to_s
      "[#{@inputs.values.map(&:to_i).join}] &#{name} -> #{destinations.join(', ')}"
    end
  end

  class Broadcast < Mod
    def send_pulse(pulse, from = nil)
      pulse
    end

    def to_s
      "#{name} -> #{destinations.join(', ')}"
    end
  end

  class Pulse
    def initialize(type)
      @type = type
    end

    def self.low
      @@low ||= Pulse.new(:low)
    end

    def self.high
      @@high ||= Pulse.new(:high)
    end

    def low?
      @type == :low
    end

    def high?
      @type == :high
    end

    def to_i
      low? ? 0 : 1
    end
  end

  LOW = Pulse.low
  HIGH = Pulse.high
end

class PulsePropagationPuzzle < Puzzle
  include PulsePropagation

  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def solve_part_one
    1000.times { machine.push_button! }
    machine.high_pulses * machine.low_pulses
  end

  def solve_part_two
    machine.split.map do |submachine|
      submachine.push_button! until submachine.rx_low_pulses > 0
      submachine.button_presses
    end.inject(:lcm)
  end

  def self.parse(input)
    mods = input.lines.map do |line|
      if line =~ /^([%&])?(\w+) -> (.+)$/
        destinations = $3.split(",").map(&:strip).map(&:to_sym)
        if $1 == "%"
          FlipFlop
        elsif $1 == "&"
          Conjunction
        elsif $2 == "broadcaster"
          Broadcast
        end.new($2.to_sym, destinations)
      else
        raise "invalid line '#{line}'"
      end
    end

    new(Machine.new(mods))
  end
end

if test?
  class PulsePropagationPuzzleTest < Minitest::Test
    include PulsePropagation

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_first_example_input_part_one
      input = <<~EOF
        broadcaster -> a, b, c
        %a -> b
        %b -> c
        %c -> inv
        &inv -> a
      EOF

      assert_equal 32000000, PulsePropagationPuzzle.parse(input).solve_part_one
    end

    def test_second_example_input_part_one
      input = <<~EOF
        broadcaster -> a
        %a -> inv, con
        &inv -> b
        %b -> con
        &con -> output
      EOF

      assert_equal 11687500, PulsePropagationPuzzle.parse(input).solve_part_one
    end

    def test_actual_input_part_two
      assert_equal 237878264003759, PulsePropagationPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
