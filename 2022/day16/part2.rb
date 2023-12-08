Tunnel = Struct.new(:destination, :length)
Valve = Struct.new(:label, :flow_rate, :tunnels)
Pos = Struct.new(:valve, :dist, :last)
State = Struct.new(:me, :elephant, :minute, :valves_open, :pressure_released) do |new_class|
  def clone
    new_state = dup
    new_state.me = me.dup
    new_state.elephant = elephant.dup
    new_state.valves_open = valves_open.dup
    new_state
  end

  def uniq_key
    me_s = "#{me.valve}:#{me.dist}"
    elephant_s = "#{elephant.valve}:#{elephant.dist}"

    # In theory, me and the elephant could switch places at any time with no effect
    us_s = me_s < elephant_s ? "#{me_s}|#{elephant_s}" : "#{elephant_s}|#{me_s}"

    "#{us_s}|#{minute}|#{valves_open.join(',')}|#{pressure_released}"
  end

  def pressure_per_minute(valves)
    valves_open.map { |v| valves[v].flow_rate }.sum
  end

  def should_try_opening_valve?(valve)
    valve.flow_rate > 0 &&
    minute < LAST_MINUTE - 1 &&
    !valves_open.include?(valve.label)
  end
end

valves = {}

File.readlines("input").each do |line|
  if line =~ /^Valve (\w+) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z, ]+)$/
    label, flow_rate, tunnels = $1, $2.to_i, $3.split(', ').map { |v| Tunnel.new(v, 1) }

    valves[label] = Valve.new(label, flow_rate, tunnels)
  else
    raise "Invalid line '#{line.chomp}'"
  end
end

# Replace valves that are just acting as tunnel extensions, with tunnels of a
# certain length.
valves.keys.each do |v|
  valve = valves[v]
  if valve && valve.flow_rate == 0 && valve.tunnels.length == 2
    tunnel_a, tunnel_b = valve.tunnels
    total_length = tunnel_a.length + tunnel_b.length

    valve_a, valve_b = valves[tunnel_a.destination], valves[tunnel_b.destination]
    valve_a.tunnels.reject! { |t| t.destination == v }
    valve_b.tunnels.reject! { |t| t.destination == v }
    valve_a.tunnels.push(Tunnel.new(valve_b.label, total_length))
    valve_b.tunnels.push(Tunnel.new(valve_a.label, total_length))

    valves.delete(v)
  end
end

initial_state = State.new(Pos.new('AA', 0, nil), Pos.new('AA', 0, nil), 1, [], 0)
states = [initial_state]
LAST_MINUTE = 26

max_pressure_released = 0
until states.empty? do
  puts "#{states[0].minute} : #{states.length}"

  # Played with narrowing down the possible states over time, and these finally
  # produced the solution in a reasonable amount of time.
  case states[0].minute
  when 10
    states.select! { |s| s.pressure_released > 100 }
  when 15
    states.select! { |s| s.pressure_released > 500 }
  when 20
    states.select! { |s| s.pressure_released > 1300 }
  when 23
    states.select! { |s| s.pressure_released > 1800 }
  end

  new_states = []

  states.each do |state|
    state.pressure_released += state.pressure_per_minute(valves)

    if state.minute == LAST_MINUTE
      max_pressure_released = state.pressure_released if state.pressure_released > max_pressure_released
      next
    end

    me_moves = []
    elephant_moves = []

    if state.me.dist > 0
      me_moves.push [:continue_move]
    else
      if state.should_try_opening_valve?(valves[state.me.valve])
        me_moves.push [:open_valve, state.me.valve]
      end

      valves[state.me.valve].tunnels.each do |tunnel|
        me_moves.push [:move, tunnel] unless state.me.last == tunnel.destination
      end
    end

    if state.elephant.dist > 0
      elephant_moves.push [:continue_move]
    else
      if state.should_try_opening_valve?(valves[state.elephant.valve])
        elephant_moves.push [:open_valve, state.elephant.valve]
      end

      valves[state.elephant.valve].tunnels.each do |tunnel|
        elephant_moves.push [:move, tunnel] unless state.elephant.last == tunnel.destination
      end
    end

    me_moves.each do |me_move|
      elephant_moves.each do |elephant_move|
        next if me_move[0] == :open_valve && me_move == elephant_move

        new_state = state.clone
        new_state.minute += 1

        case me_move[0]
        when :continue_move
          new_state.me.dist -= 1
        when :open_valve
          new_state.valves_open.push(me_move[1])
          new_state.valves_open.sort!
          new_state.me.last = nil
        when :move
          tunnel = me_move[1]

          new_state.me.valve = tunnel.destination
          new_state.me.dist = tunnel.length - 1
          new_state.me.last = state.me.valve
        end

        case elephant_move[0]
        when :continue_move
          new_state.elephant.dist -= 1
        when :open_valve
          new_state.valves_open.push(elephant_move[1])
          new_state.valves_open.sort!
          new_state.elephant.last = nil
        when :move
          tunnel = elephant_move[1]

          new_state.elephant.valve = tunnel.destination
          new_state.elephant.dist = tunnel.length - 1
          new_state.elephant.last = state.elephant.valve
        end

        new_states.push(new_state)
      end
    end
  end

  states = new_states.uniq(&:uniq_key)
end

p max_pressure_released
