Position = Struct.new(:x, :y)

class Sensor
  attr_reader :pos, :beacon_pos

  def initialize(pos, beacon_pos)
    @pos, @beacon_pos = pos, beacon_pos
  end

  def dist_to_beacon
    (@beacon_pos.x - @pos.x).abs + (@beacon_pos.y - @pos.y).abs
  end

  def range_covered_at_row(row_y)
    half_width = dist_to_beacon - (row_y - pos.y).abs
    (pos.x - half_width)..(pos.x + half_width)
  end
end

class RangeSet
  def initialize(ranges = [])
    @ranges = []
    ranges.each { |r| insert(r) }
  end

  def insert(new_range)
    idx = 0
    while idx < @ranges.length do
      cur_range = @ranges[idx]
      if cur_range.begin >= new_range.begin && cur_range.end <= new_range.end
        @ranges.delete_at(idx)
      elsif new_range.begin >= cur_range.begin && new_range.end <= cur_range.end
        return
      elsif new_range.include?(cur_range.begin)
        new_range = (new_range.begin..cur_range.end)
        @ranges.delete_at(idx)
      elsif new_range.include?(cur_range.end)
        new_range = (cur_range.begin..new_range.end)
        @ranges.delete_at(idx)
      else
        idx += 1
      end
    end
    @ranges.push(new_range)
  end

  def size
    @ranges.map(&:size).sum
  end

  def include?(value)
    @ranges.any? { |r| r.include?(value) }
  end
end

sensors = []
File.readlines("input").each do |line|
  if line =~ /^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/
    sensors.push(Sensor.new(Position.new($1.to_i, $2.to_i), Position.new($3.to_i, $4.to_i)))
  else
    raise "Invalid line '#{line.chomp}'"
  end
end

range_set = RangeSet.new(sensors.map { |s| s.range_covered_at_row(2_000_000) })

num_covered_beacons = sensors.map(&:beacon_pos)
  .select { |p| p.y == 2_000_000 && range_set.include?(p.x) }
  .uniq
  .length

p range_set.size - num_covered_beacons
