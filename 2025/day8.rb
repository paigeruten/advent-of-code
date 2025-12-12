NUM_TO_CONNECT = 1000

junction_boxes = File.readlines(ARGV.first).map { it.split(',').map(&:to_i) }

def sorted_pairs(junction_boxes)
  pairs_with_distance = []
  0.upto(junction_boxes.length - 2) do |i|
    (i + 1).upto(junction_boxes.length - 1) do |j|
      a, b = junction_boxes[i], junction_boxes[j]
      distance_squared = a.zip(b).map { it[0] - it[1] }.sum { it * it }
      pairs_with_distance << [a, b, distance_squared]
    end
  end

  pairs_with_distance.sort_by { it[2] }.map { it[0..1] }
end

def largest_circuits(junction_boxes)
  connections = {}
  sorted_pairs(junction_boxes).take(NUM_TO_CONNECT).each do |a, b|
    (connections[a] ||= []) << b
    (connections[b] ||= []) << a
  end

  circuits = []
  seen = {}
  connections.keys.each do |point|
    next if seen[point]
    seen[point] = true

    circuit = [point]
    i = 0
    while i < circuit.length
      cur_point = circuit[i]
      connections[cur_point].each do |neighbour|
        unless seen[neighbour]
          circuit << neighbour
          seen[neighbour] = true
        end
      end
      i += 1
    end

    circuits << circuit
  end

  circuits.map(&:length).sort.last(3)
end

def final_connection(junction_boxes)
  circuits_by_id = {}
  circuit_ids_by_pos = {}
  junction_boxes.each.with_index do |pos, id|
    circuits_by_id[id] = [pos]
    circuit_ids_by_pos[pos] = id
  end

  sorted_pairs(junction_boxes).each do |a, b|
    a_id, b_id = circuit_ids_by_pos[a], circuit_ids_by_pos[b]
    next if a_id == b_id

    circuits_by_id[b_id].each do |cur_pos|
      circuits_by_id[a_id] << cur_pos
      circuit_ids_by_pos[cur_pos] = a_id
    end
    circuits_by_id.delete(b_id)

    return [a, b] if circuits_by_id.length == 1
  end
end

puts "Part 1: #{largest_circuits(junction_boxes).inject(:*)}"
puts "Part 2: #{final_connection(junction_boxes).map(&:first).inject(:*)}"
