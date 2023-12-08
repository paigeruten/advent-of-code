require 'set'

def floor_possible?(floor)
  floor.each do |item|
    if (item[0] == "M" && (!floor.include?("G#{item[1..-1]}".to_sym) && (floor.any? { |x| x[0] == "G" })))
      return false
    end
  end
  true
end

def dup_state(state)
  new_state = state.dup
  new_state[1] = state[1].dup
  new_state[2] = state[2].dup
  new_state[3] = state[3].dup
  new_state[4] = state[4].dup
  new_state
end

INITIAL = [
  1,
  Set.new([:Gstrontium, :Mstrontium, :Gplutonium, :Mplutonium, :Gelerium, :Melerium, :Gdilithium, :Mdilithium]),
  Set.new([:Gthulium, :Gruthenium, :Mruthenium, :Gcurium, :Mcurium]),
  Set.new([:Mthulium]),
  Set.new
]

#INITIAL[1].delete :Gelerium
#INITIAL[1].delete :Melerium
#INITIAL[1].delete :Gdilithium
#INITIAL[1].delete :Mdilithium

states_seen = Set.new
states_seen.add INITIAL
states = [INITIAL]
step = 1
loop do
  next_states = []
  states.each do |state|
    if state[1].empty? && state[2].empty? && state[3].empty?
      p step
      exit
    end
    old_floor = state[0]
    [state[0] - 1, state[0] + 1].each do |new_floor|
      if new_floor >= 1 and new_floor <= 4
        # take one item
        state[old_floor].each do |item|
          new_state = dup_state(state)
          new_state[0] = new_floor
          new_state[old_floor].delete item
          new_state[new_floor].add item

          if floor_possible?(new_state[old_floor]) && floor_possible?(new_state[new_floor])
            unless states_seen.member? new_state
              next_states << new_state
              states_seen.add new_state
            end
          end
        end

        # take two items
        if new_floor > old_floor && state[old_floor].length >= 2
          ary = state[old_floor].to_a
          0.upto(state[old_floor].length - 2).each do |i|
            (i+1).upto(state[old_floor].length - 1).each do |j|
              isym = ary[i]
              jsym = ary[j]
              new_state = dup_state(state)
              new_state[0] = new_floor
              new_state[old_floor].delete isym
              new_state[old_floor].delete jsym
              new_state[new_floor].add isym
              new_state[new_floor].add jsym

              if floor_possible?(new_state[old_floor]) && floor_possible?(new_state[new_floor])
                unless states_seen.member? new_state
                  next_states << new_state
                  states_seen.add new_state
                end
              end
            end
          end
        end
      end
    end
  end
  states = next_states
  step += 1
  p step
  p states.length
end

