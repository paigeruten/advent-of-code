class Packet
  include Comparable

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def self.from_str(str)
    self.new(eval(str))
  end

  def <=>(other)
    a, b = self.value, other.value
    return a <=> b if a.is_a?(Integer) && b.is_a?(Integer)

    a = [a] if a.is_a?(Integer)
    b = [b] if b.is_a?(Integer)

    (0...a.length).each do |i|
      return 1 if b[i].nil?
      order = Packet.new(a[i]) <=> Packet.new(b[i])
      return order unless order.zero?
    end

    a.length <=> b.length
  end
end

packets = File.readlines("input")
  .map(&:chomp)
  .reject { |line| line.empty? }
  .map { |line| Packet.from_str(line) }

packets.push Packet.new([[2]])
packets.push Packet.new([[6]])

packets.sort!

divider_packets = [
  packets.find_index { |p| p.value == [[2]] } + 1,
  packets.find_index { |p| p.value == [[6]] } + 1
]

p divider_packets.inject(:*)
