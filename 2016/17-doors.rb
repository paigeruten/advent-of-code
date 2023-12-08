    require 'digest'

    PASSCODE = 'vwbaicqe'

    last_finished = nil
    found_shortest = false
    paths = [["", 0, 0]]
    until paths.empty?
      next_paths = []
      paths.each do |dirs, x, y|
        md5 = Digest::MD5.hexdigest("#{PASSCODE}#{dirs}")
        "UDLR".chars.select.with_index { |_, i| "bcdef".include? md5[i] }.each do |dir|
          path = [dirs + dir, x + {?U=>0,?D=>0,?L=>-1,?R=>1}[dir], y + {?U=>-1,?D=>1,?L=>0,?R=>0}[dir]]
          next if path[1] < 0 or path[1] >= 4 or path[2] < 0 or path[2] >= 4
          if path[1] == 3 and path[2] == 3
            if !found_shortest
              found_shortest = true
              puts "Shortest: #{path[0]}"
            end
            last_finished = path
          else
            next_paths << path
          end
        end
      end
      paths = next_paths
    end

    puts "Longest: #{last_finished[0].length}"

