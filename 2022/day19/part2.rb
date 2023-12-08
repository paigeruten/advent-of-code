LAST_MINUTE = 32

def dup_state(state)
  {
    materials: state[:materials].dup,
    robots: state[:robots].dup
  }
end

class Blueprint
  attr_reader :id, :robots

  def initialize(id, robots)
    @id, @robots = id, robots
  end

  def initial_state
    state = { materials: {}, robots: {}}
    @robots.each do |robot|
      state[:materials][robot.material] = 0
      state[:robots][robot.material] = robot.start_with
    end
    state
  end

  def max_possible_geodes
    states = [initial_state]
    (1..LAST_MINUTE).each do |minute|
      puts "  Minute ##{minute}: #{states.length} state#{'s' if states.length != 1}"

      next_states = []

      states.each do |state|
        initial_materials = state[:materials].dup

        @robots.each do |robot|
          state[:materials][robot.material] += state[:robots][robot.material]
        end

        # Option 1: Do nothing
        next_states << state

        next if minute == LAST_MINUTE

        # Option 2: Build a robot (if we have enough materials)
        @robots.each do |robot|
          next unless can_build_robot?(robot, initial_materials)

          next_state = dup_state(state)
          next_state[:robots][robot.material] += 1
          robot.cost.each do |material_needed, amount_needed|
            next_state[:materials][material_needed] -= amount_needed
          end
          next_states << next_state
        end
      end

      next_states.uniq!

      # Hacky optimization: Only keep states in the top 30-50% for # of geodes
      if minute > 22
        cutoff = (self.id == 1 ? 0.5 : 0.3)
        next_states.sort_by! { |s| s[:materials][:geode] }
        next_states = next_states.last((cutoff * next_states.length).ceil)
      end

      states = next_states
    end

    states.map { |state| state[:materials][:geode] }.max
  end

  def can_build_robot?(robot, materials)
    robot.cost.each do |material_needed, amount_needed|
      return false if materials[material_needed] < amount_needed
    end
    true
  end
end

class Robot
  attr_reader :material, :cost, :start_with

  def initialize(material, cost, options = {})
    @material, @cost = material, cost
    @start_with = options[:start_with] || 0
  end
end

blueprints = File.readlines("input").map do |line|
  blueprint_id, *costs = line.scan(/\d+/).map(&:to_i)

  Blueprint.new(blueprint_id, [
    Robot.new(:ore, { ore: costs[0] }, start_with: 1),
    Robot.new(:clay, { ore: costs[1] }),
    Robot.new(:obsidian, { ore: costs[2], clay: costs[3] }),
    Robot.new(:geode, { ore: costs[4], obsidian: costs[5] }),
  ])
end

max_geodes_product = 1

blueprints.take(3).each do |blueprint|
  puts "Blueprint ##{blueprint.id} (of #{blueprints.length}):"
  max_geodes = blueprint.max_possible_geodes
  puts "  Max geodes: #{max_geodes}"
  puts

  max_geodes_product *= max_geodes
end

puts "Product of max geodes: #{max_geodes_product}"