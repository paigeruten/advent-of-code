require 'set'

Tunnel = Struct.new(:destination, :length)
Valve = Struct.new(:label, :flow_rate, :tunnels)
State = Struct.new(:valve, :minute, :valves_open, :pressure_released) do |new_class|
  def clone
    new_state = dup
    new_state.valves_open = valves_open.dup
    new_state
  end

  def to_s
    "#{valve}|#{minute}|#{valves_open.join(',')}|#{pressure_released}"
  end

  def pressure_per_minute(valves)
    valves_open.map { |v| valves[v].flow_rate }.sum
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

initial_state = State.new('AA', 1, [], 0)
states = [initial_state]
states_seen = Set[initial_state.to_s]
LAST_MINUTE = 30

max_pressure_released = 0
until states.empty? do
  new_states = []

  states.each do |state|
    state.pressure_released += state.pressure_per_minute(valves)

    if state.minute == LAST_MINUTE
      max_pressure_released = state.pressure_released if state.pressure_released > max_pressure_released
      puts state.to_s
      next
    end

    if valves[state.valve].flow_rate > 0 && state.minute < LAST_MINUTE - 1 && !state.valves_open.include?(state.valve)
      new_state = state.clone
      new_state.minute += 1
      new_state.valves_open.push(state.valve)
      new_state.valves_open.sort!
      new_states.push(new_state)
    end

    valves[state.valve].tunnels.each do |tunnel|
      minutes_to_pass = [tunnel.length, LAST_MINUTE - state.minute].min

      new_state = state.clone
      new_state.valve = tunnel.destination
      new_state.minute += minutes_to_pass
      new_state.pressure_released += (minutes_to_pass - 1) * new_state.pressure_per_minute(valves)
      new_states.push(new_state)
    end
  end

  states = new_states.select { |state| states_seen.add?(state.to_s) }
end

p max_pressure_released
