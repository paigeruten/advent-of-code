RULES = {}

File.readlines("../input/day24").each do |line|
  if line =~ /^(\w+) (AND|OR|XOR) (\w+) -> (\w+)$/
    RULES[$4.to_sym] = [$2.downcase.to_sym, $1.to_sym, $3.to_sym]
  end
end

def swap!(a, b)
  RULES[a], RULES[b] = RULES[b], RULES[a]
end

def related_wires(wire)
  result = [wire]

  rule = RULES[wire]
  if rule
    result += related_wires(rule[1])
    result += related_wires(rule[2])
  end
  result.uniq
end

def diagram(wire)
  puts "flowchart TD"
  related_wires(wire).each do |out|
    rule = RULES[out]
    if rule
      if %w(xx xy yx yy).include?(rule[1].to_s[0] + rule[2].to_s[0])
        puts case rule[0]
        when :and then "    #{out}[#{rule[1]} AND #{rule[2]}]"
        when :or then "    #{out}(#{rule[1]} OR #{rule[2]})"
        when :xor then "    #{out}{{#{rule[1]} XOR #{rule[2]}}}"
        end
      else
        out_label = "#{out}: "
        out_box = case rule[0]
        when :and then "#{out}[#{out_label}AND]"
        when :or then "#{out}(#{out_label}OR)"
        when :xor then "#{out}{{#{out_label}XOR}}"
        end

        puts "    #{rule[1]} --> #{out_box}"
        puts "    #{rule[2]} --> #{out_box}"
        if out.to_s.start_with? 'z'
          puts "    #{out_box} --> #{out}end[#{out}]"
        end
      end
    end
  end
end

swap!(:hmk, :z16)
swap!(:fhp, :z20)
swap!(:rvf, :tpc)
swap!(:fcd, :z33)

diagram(:z34)
