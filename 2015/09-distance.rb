dist = {}
DATA.each do |line|
  if line =~ /^(\w+) to (\w+) = (\d+)$/
    dist[$1.to_sym] ||= []
    dist[$1.to_sym] << [$2.to_sym, $3.to_i]

    dist[$2.to_sym] ||= []
    dist[$2.to_sym] << [$1.to_sym, $3.to_i]
  end
end

num_cities = dist.keys.length
routes = dist.keys.map { |start_city| [0, start_city] }

until routes[0].length == num_cities + 1
  new_routes = []
  routes.each do |route|
    dist[route.last].each do |dest, len|
      unless route.include? dest
        new_route = route.dup
        new_route << dest
        new_route[0] += len
        new_routes << new_route
      end
    end
  end
  routes = new_routes
end

p routes.max_by(&:first)

__END__
Tristram to AlphaCentauri = 34
Tristram to Snowdin = 100
Tristram to Tambi = 63
Tristram to Faerun = 108
Tristram to Norrath = 111
Tristram to Straylight = 89
Tristram to Arbre = 132
AlphaCentauri to Snowdin = 4
AlphaCentauri to Tambi = 79
AlphaCentauri to Faerun = 44
AlphaCentauri to Norrath = 147
AlphaCentauri to Straylight = 133
AlphaCentauri to Arbre = 74
Snowdin to Tambi = 105
Snowdin to Faerun = 95
Snowdin to Norrath = 48
Snowdin to Straylight = 88
Snowdin to Arbre = 7
Tambi to Faerun = 68
Tambi to Norrath = 134
Tambi to Straylight = 107
Tambi to Arbre = 40
Faerun to Norrath = 11
Faerun to Straylight = 66
Faerun to Arbre = 144
Norrath to Straylight = 115
Norrath to Arbre = 135
Straylight to Arbre = 127
