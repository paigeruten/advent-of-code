# you must increase/decrease x by 2 to travel to an adjacent hexagon horizontally.
# when y is even, x must be even. when y is odd, x must be odd.
DIRECTIONS = {
  :ne => [1, 1],
  :nw => [-1, 1],
  :se => [1, -1],
  :sw => [-1, -1],
  :e => [2, 0],
  :w => [-2, 0]
}

black_tiles = {}
DATA.readlines.each do |line|
  steps = line.scan(/(ne|nw|se|sw|e|w)/)

  x, y = 0, 0
  steps.each do |dir|
    dx, dy = DIRECTIONS[dir.first.to_sym]

    x += dx
    y += dy
  end

  black_tiles[[x, y]] = !black_tiles[[x, y]]
end

black_tiles.select! { |_, is_black| is_black }

100.times do
  next_black_tiles = {}

  xs = black_tiles.keys.map(&:first)
  ys = black_tiles.keys.map(&:last)

  min_x, max_x = xs.min - 2, xs.max + 2
  min_y, max_y = ys.min - 1, ys.max + 1

  min_y.upto(max_y).each do |y|
    # ensure our hexagonal coordinates are valid.
    start_x = (y % 2 == min_x % 2) ? min_x : min_x - 1
    end_x = (y % 2 == max_x % 2) ? max_x : max_x + 1

    start_x.step(end_x, 2).each do |x|
      is_black = black_tiles[[x, y]]
      num_neighbours = DIRECTIONS.count { |_, (dx, dy)| black_tiles[[x + dx, y + dy]] }

      if num_neighbours == 2 || (is_black && num_neighbours == 1)
        next_black_tiles[[x, y]] = true
      end
    end
  end

  black_tiles = next_black_tiles
end

p black_tiles.count

__END__
nenwnwnwnwnewnwsenwnwnwsenwnwsenwnenww
eeeeeenewsweneeeeseeenwwnene
seeesesesenweeseewnw
nesesweneewseeseeseenwweeswesw
neeneeswneeeeeeeneeneeneweee
seseesenwsesesesesesesesenewseeseswsese
senwwwenwneswnwnwewswsewnesewesw
swswswswswnwseswwswswswswswswswsweswnw
neeneeweeeeseeneneeseeneneenenwe
seneswwnenewsewesenenenenenenenwnenenene
wwnwnenwsenwwnwwwwwwwwwwnww
seeeeneenesewseeswneeewnwseseswse
nwwwsenwnwwwwewwwwewnwwwwswnw
neneswenenenenenesweneneenewnwenenewne
nwwwneseswswnwesenwnesewswwsenwseww
nwwwnwnwnwnwnwwnwnwsewnwnwnw
nwsewsenenenwnweswnwnenwenenwswnwnwnwnw
nwnenwneewnwneswwnwnenwnwnwnwnwnwnwese
nenwneneenwnewnwnwnenw
seswswseswwseneswswsenwseswseswswe
swseswwswswswswswnwswswswswwnwseswswsww
wswseswswseswswsweswswneeseswwnwswnesw
nenenenwnwnwnenwnesenwnwnwnwnewnenenwnw
seneswnenwnenwnenewneseenwneneswnwnenenwne
nwnwnwnwnwnwnwswnwnwenwnwnwnwnwnwnwnww
nwweenweswneneneneneneeseeesewnene
nwswswswswswsweswswseswswswswswswswswsw
eeeenwneneeswneeeeneneneneeeneew
swwsewwwnwswnwwenewswswwseswswnesw
eswseswneneseswswwsenwseswswsesw
wewnewwwswswewsewneswswswswwwsw
eneeneeneneeneweenewneneeenenesw
enweneeesesesesesewneswneswesesewse
nwswswswwwswwswswwwswwswswswewsw
eeseweseseswseneseeseseeseseesee
nwswswswswswswswswnenewwswswwsenweswsw
wwwnwsesewnenewswsenenewww
neneneneneneneneeswnenwneneneswnwnwnenwnw
nenwnenwnwneswswswsewnenwnwneeswswnww
ewswswnewnwswwswswswswnesweswnwsesesw
nweenwnwnwswwnwnwnwnwwswnwnwnwenwswnwnw
senenwneneneeswneeeswnewenwnewswne
swsesweswnwwswswswswsweseseseswswwsene
swswweswnwwswnwwnwswwseewwwwsw
ewenwswwwwwwwwnwsewnwnenwsenww
eneenesenwswnenwnwnwneneneseseeswenwsw
sesesesenewnwnewsewseesewseseseesene
neeweneseeeeeswenweeneeswee
nwseseeeseeeeeseseewseweesenwe
eenweeneneeeeneseee
nwnwnwnwnwswnwnwnwnenwenwnwnwnwnwwswnw
sesenenwweseseeseesweeeneeseeese
nwenenenwnenwnenwnwsenwwnwsenwneseswsw
enwneneenwseswwneswwnwneswneseswwe
swswswswswwswseeswswswwneseseswswsese
nwnwnwenwneswnwnenenwwnwnwnwnenwnwnwne
nwwnenwewswswswswewswsweswenwswnwsw
nwwnesweswwswswwwwwewwwswwsww
sweeseeeeeeeenweeeeenwesw
wsewnewwwwnwwwwswwwwnew
wewwwswnewsesenewswswwwwwww
eeewneneeeeeeeseswesweseesee
nwwnwnenwneneswseneswsenwsenewenesenene
nwnwnwnwsenwnenewnwnwnwnenwnwnwsenenwnene
swswswswenwswseseeswnwswnwne
wesenwnwneenwnwnwnwnwnwswnwwnwnwnwsww
eeeweeeneenwneeesweseeeeee
neeswneswnewswswswnenenenwnenenwnenenenw
nwnwnenwnwnenwnenwwenwnwswwnwnwnwsenwe
wwwnwwwwwwwewwewwnwwwwnw
wnweswswwwwnwnwnwwnwnwwnewswnenwnw
nwsenwnwenwsewnwnwnenwnewnwenewnenwswnw
swnwsewweseswwsesesewnenesenesenesw
swwswswswsweswswswswswswswsw
nenewswneswneneneneneneneseneswnenenene
eswnwswswseswswswnwseswseeswseswseswsesew
newnewneneseeweeee
senwwseeseswseseseeseswswswswseswseswse
wsenenewneneweneeneseneneneeneenee
eneseseswsesewswseseseseew
wweneswwswswwwsewwswswwnwswwwsw
eeseeeewsweweseeeeenwewe
nwnewnwnwewswenenwnenwenwswnwneswnw
nenwseswnesesesweseseseswenwseewsesee
nwnewwseswwsenwnwneewnesenenwesenw
wnenenwnewneseneneneswswnesenwnwneenenene
esesesenwswseseseeeseeswsenwe
swswswswswswwswneswswwswwswswsww
neswsweswneneeeswwswwnwenwseswnenenene
nwswnenenenenwnenenwneneneneneswneenwnw
eesenweneeseseeeeswseeweesenw
swneneswnwenenwnwsenwnwnwnwnenwnwnwenw
nwnwsenwwnwnwsenwnewwwnwnwnwnwnw
nwseseneeewsenwnenenwneseswsweseswesw
nwnwnesenwnwnwwnwnwnwswnwnwnwnenwnenwne
eswswnewseswsenweswswswnesenewswswsw
eeneswneeeweneseswenenwnee
nenenwneseswwnwneneewnwenwswwswese
sewwwnwwwwwenwswwwwwwwwnw
eeewnweeneseeesweeeeweewswe
newsewswneeseswseseeseeseenesenwe
nwnwnwenwswneswsenwnwnwwnwnenenwswnwnwe
swnwswswswneswsesweswsewswseswswswseswnwsw
nwwwnwwsewwnweneswwwnwwewwww
wwswnwwwewnwwwsewnwnenwnwwwww
swswsweswswswswswneswneswswseswsesew
seeeeeeeeeeeeeeeenwswee
swseswseneswswswwswswswsesesesewneswsw
sesenwwnwseewnenwsee
seseeseseeseseeswseeesesesenwwsee
wseswsenenesweenwwswwnwwswnwnwenw
eneeeeeewenwweseseseeeneswese
swswseswseseswwseneseswswsweswsesesw
enwswsenwwnwnwnwsewwnwwewwnwnwwsw
nenwnwneneswnwnwwnwnwsenwwnwnenwsenwne
eseseeeneneeeeeeweeewesesew
seseswseeseswnwseswsesenwswseswnwseesenese
swswwsenwnewswsewsewsenwswwwnenenwse
nwswwswswwwswswswswswswswswseswnwesw
swwnwnwwnwsenwnenwenwwwnwnwnwnwnenwnww
neeneneneswnwneneenenenenwnenenwneneneswne
swneeswnenenenenenwnwswswnwewsenenene
seweweswseswswnenewnewswswnewenwne
wsewwwweswwnewwwsewswnewwew
newnwnwnwnwnwnwnwnwnwnwnwnwnwnwenw
swsenwswseseseseswnwswswswswsweswsesesese
nwnwnwwnwwwwnwwnwwwwse
nwnenwenenenwwnwnwnwnenenenenwnewene
sweseswnwnwswwsweswswswseseswswnwswsene
swwnewnweswewweneswesewenwswsw
nweeneswnwswswsesesesewwe
weswwnwswswsenwsewwswneswwswwww
nwnwnwneswnwnwnwnwnw
swswswswswswswswenwswswswswswnewswswswsw
nwnenwnwnwswswneneswsenwnwnenwnwnwswnenwnw
seseeseseswsenwseeseseneseseseseenwse
neenwnwnwwnwnwswnwnw
sesesewsesesesesesesesenesesewsesene
eeeneeeneneeenesweeenweeenesw
swsesesesenwswesweseswnwswsenwswseswsw
eseseseswseeeeswneesesesenweseeewe
neseeeeenweeeeneeeeneeneesenw
seeseseseseseseswswsenwsesewsesesesese
wswewwwwwewwswswwwwwwww
nwnwnwnwnwneenwnwnwsenenwnwnwsenwwnwnw
wwsewwwwwwnewnwwwwnwnwwwnw
swswseswswswswswsweswswswswwsweswswswnw
nenwnwnenwnenwnwneswnwnenwnwnwnwsenenesw
eweeseesweeeenwnwseswneeswnwenw
nenenewnenwnenwesenenenenenwne
nwenwsesenwseneeseneesenwseswwswsww
swswsenwnenwswswswseswwenenenwswswsese
wnewsewwnwwwwwwwwwnww
nwnenwnwnenenwnwnwnwnwnenwnwnwsenwnwnww
wwwneswwsenwwsenwwweewnwwnwnwe
wnewsewwnwwwswwenenwwnwsew
nwseswwsenwnwswnwneenewweneswwswne
weweeseseweswnwene
nwnwsewnwwnwnwwwwnwnwnwnwnwnwnw
enwseseswswswswswneswwswneswnewswswwsw
seswwenwnwwwwwsenwwwwnwswnewnwwnw
wnwwnwwwsenewnenwnwswwwwwnwwnwnw
neneneenewneenenesewneeeneneeene
wneswnwwwwwswwwwwseeseewwsw
neswnenenenwneneneenenenenwnwnwnenenene
nwnwnwnwsenwswnwnwnwnwnwnwnwnwnwenwnwnw
nenwseseneweseneneswwwseswsewswsesese
esesweseeeseeseseeeseeenwseese
sweneseswseseseseeseneseseesesesesee
nwnwnwswneneneneenwnenwnenenwnwnenw
nwwwswewsesewneww
wwwwwnewswwwswwwwwewwwwsw
sewwwneswswwsewnwnwwewwwwwe
nwnwnwnwnwnwnwnwnenwenwswnwnwnwnwnwnwnw
swswswswwswswnwswswwwswswswseswneswse
senewseseseswsewneswseweseseesesene
swseswswswneeswswswswseswswnwswswwswsw
nwesweenewsweneeneenesewneseee
eswseseseesenwseeenwnwseeseseesee
nwnewsenwwwwwwnewwwsenwnwnwww
eneneneneweneewenenene
senwnwnwnwnwnwnwnwnww
eneeeeneneeeeeeseeneeenewne
eseswswswswnwswswswswnwswseneswswswsww
nwwnwwnwnwnwnwnwsenwwenwnwnwnwsenwnw
wswsweswswswswwswswwwsenewswswwsww
enenewneneeeenenewsenewsenenene
eseeeeeseeeseeeesenwsweeese
eneeswwsewneseeeneseseeneewwee
swseseneswnwswswwswswswswswseswsweswswsese
neesewesesenwewneeeeneeneeeenwsw
eswwseenweseenweeeseeeeseee
wswseswneseneeswwnwsewse
sweswswswwseneswswneswewnwswneseseswsw
sesenwseseeseseseeenwseseeswnwsesee
seseswnwswseswswswswneseseswswseseswswsesw
nenweswwseeneeneneenenenesenenenenwnene
nwnwnwnwnwnwnwnwnwnwnwnwenwnwnwnwnwnwsw
swswwwwwswwneseswswwswwwwwswew
nwnenwnwnwwsenenwsenwwnwnenwenwnenwnwnwnw
wsewnwnwnenwnwnwnwnwnwsenwnwnwnwnwnenw
nenenenenwneeeeeeneeneeneeneseswe
wnenenenwnewnwnenenwnenenwseenenesenwne
nesenwsewnenwswenwneesewswnwswnesww
wwnwenwewswswwnwwseswnesweswnww
neneneenwneeneneneneswnenwneneneswneswne
nwnwswnwenwnwwewnwnweswnwnwwwnwwsww
eeeeeweeeneeeseseseeeesee
wwwwwswnewwwneswsewwwwwww
nweeswwseeseeenweeeeenene
nwnwnwnenenwnwnwnwsenwnwnwnwnww
seweeeseseseseeseeseeeeewesese
wseewseneseeseseesesese
senenwnwswnwnwswnenwnwnweswwwnwnwnene
swseseseesesesesewseseseenesesesewsese
seswswewseswswneswse
nenwnwnwnwnwnwenwnenenwswnenwnwswnwnwnwnw
neneeswwswnenwnwenwnenewnwnwnwnesewe
wnwnwswwnweeenenwsenwseenwnwwswnw
eeseseseeeeeeseeseneesewswnwse
neswseswewswsweswwswseswswwswswnwesw
nwwnwewsewnesewnwwsewww
weseeneneneeenesenweesenwwenenenee
nwwnwwenwnwnwswwwnwwnwnewnwnwswnww
nwwnwnwnwnwnwenwnwsenwnenwwnwnwnw
wsewseesenwneswnenenwenesewwwsww
swsesesesesesesenwwnese
newswewenenesewsenwweesweseenenw
nwnwnwnwnwnwnwnwsenwnwnwnwnwnw
swsweeswswseeneswswswnwwwswwnenwswsww
neneeneswneneneewnesenenenesenwnenw
nwnesenwnwnwnwnwnenwnwnw
nwnwswnwwwsewnwnwwsenenwwnenwnwswnwne
nwenwseseseeeeswsesesesesenwseweese
nwnwnwnwnwnwsenwnwwnwnwnwwnwnwnwnwnw
seneweseseseswnwswesesewseneseseswnew
eeeseseeeeeeseeseswnweeene
swnwseeeswnwseeseeseseesenw
swswswswsesweseswswseseswswseswswswnwsenew
swseseseswneneswswseswewsesweswswswnw
ewwswnewwwwnwswnwwwenwwwww
newneneeneseswwwseswwnenweenwseene
nwseswsesweseswswseswswnwnwswswseeseswsw
eeneeswneneeneseeeweenenenwnee
wsesesewswseeseseseseswseseswsesesenwne
swswnewewswsewnewwwnewwnwwnwew
swseswswneswwnwswneeww
sweswneeeeewneseenwneew
nwnwnwwwenesenwnwwnwnwswsenwenwswnwe
nwneenenwwsenenenenenwswsenenwneswnwnenew
wwwwsewswwwwnewwwwwwwnwww
wneneneeneseneeeeeneneneneneneene
seseeseeseeeseeesweseeesewnwew
seseeeswnwseeseseewseseeseseseeseese
seswsesesesenwsenwseseseswsesesesesesesese
swsweswswswswswnwswswswswswswneswswswsw
eeeeeweseeee
eewseseeeseeeseseeswsenesesesesenw
sewsewneseswseseweseneseeenwsewnwse
wnwwwwnwnenwwnwnwnwnwwswwnwwewnw
eeseseeewsesweeseneneseeeseee
neneseswseeeewneeeeseseswwseswee
neneeswenenweeneneenenenesewneeneene
swnwnenewwswseswwswsw
seseseswsesesesesesesesesenewwsenesese
nenesenesewesewsewneswseswneneswswse
neswswswswswswswneswseswwseswsenwneseswsw
neeeneeneneneneswnenwswneneneswnwenene
wwwwswwwnewwwswnwnwswseswwwesw
swneenwneeneewnenenenenewneswnenene
swswseseswswswseseneeswnwsesenwswswsese
senesenwsenenewnenwenwsenenwswenwnwwne
seseenwseenwseswseesesesesesesesesese
senwnwswnwnwswnwnenwwseeneneeswswnwnwne
nwwwnwnwwnwnwwewesewnwwwwwnw
enwnenweeseswnweewseneesweneeene
swswseseswsenwseseseeeswseseswswswnwsewse
nwwnwnwnenwseseswnwnwswnwne
senewseseseseeseseseseseeseeseseese
swswnwnwnwnenwnwnwnenwnwnwnenwwnenwsenwnwnw
neeneeneweeneeenweneseeeseswne
senenwnwnwnwnwnenenenesw
swswswwswneswnenwsesesweneswwswswswnew
nesewseeeseseseseesesee
eeeswnweweeeneeneneneeneeneee
senenenwnwnwswnwenenenwnwnenwnenene
senwnwnwnwwnwnwnwnwnwnwnwsewnwnwwnwnwnw
seseswseseseswseswwwseseseswsesweneswsese
eswnwsenwswswnwenenesesewwswnwnewe
eneneeseneeeeeeeseweeneneswenwnw
swwnwwswswnwswwseweswswweeswswsw
wswnwnewnwswweewsewnewnwnwseswsese
wwswwwswwswswnewswwnewswswswseswsww
sesesenesesesenwsewseseseseseewesesese
swneseswseswseswswswswswwswseseenewsese
ewswneseneswnwsesenwsewwnwenesewnew
eswnenwswnesweenwnwnwnwnenewneswsene
neweeeeneseeeeeeenewnenene
seseseseseeseseseseseseseesesesewwsene
swswswswswswswswswswswswswwswswswswewne
neenenewnwnenenenesenwneneswnwnee
nwewnwewsewswenewwseswswnwneneswne
swswseswneneseeswswseswseneseseswsewnw
wneneneenenenwnenwwnenenenenwneneene
weswnwnenwwsewswwwne
nwnenwnwnwnwswnwnwenwnweswnwnwsenwnwnwswnw
wnwwsenwswwnwnwnwenwwswnwwnwsenwwnwe
nwseeseswswseswseseswnewwseneseswseswsene
wwnwnenwwwswnwwwwweswnwwwwese
swseswswswswweneswswnenwseswneswnwswsw
ewswneeeseesewseeeseseeenewe
seswneseseswwswseseseseswseseswseseswsw
neneweneeeeesweneeenee
seeeseneweswnwwenweneenenwnesesw
eeeeeeeewesesesesesesesesesewse
newwenesesewseseseseswseswsesesesesese
eeseeseeweeneewseeeeeeeeee
swswwswwswswwswwwseweneneswswsesww
eeeweeeeseeeeeeeenweswe
wnwwwnwenwwwneseeseenwwnw
eewewesweneenenweewsweseweene
enwseswswnweswwswseneeenenewsenese
sweseswneseswswswswswswseswseeseswswnwswnw
eneswswnewwnwnwwnwsenwwee
swwwnwnwwnwwsewsewnwnwnewwnwenw
wenenwnenenwnenwneneneneneenenwwnwne
wnewwnwwsenwwnwwnwnwswnwwnwnwwwnw
wnwwwwwseeeneswnwnwnenesenwswsewsew
neneneneswnenenenenenenwnwnenesenenenenwne
nwwwwwwwswwwenww
nwseswwswnenenesenewesenw
swnwnwnwesweneseswnenenwnwnenenenenenw
eswwswswswwneswswwswwwewneswwswse
swneeseswnwswseswnwseseweeseenwswsew
wnwnenenenenwsenenenenenenenwnenene
neneseneeneneneneneneneneneeneenwswene
eenwenesenewsenenwneswewsw
swseseswseseeswneseswswswswswsesesenwsw
neeeneneneneneneneneneneneswnenenenewne
wnwnwnwwwswnwwnwnwwwnwnwnwnwnwenenw
neeswneewseeneeneneneneneneneneeeene
wswwwsewwwwwwwwwnwwweww
seseseswenwnwseesesesewseswnwsesesese
newneseeeseneneseswseewswenwseeese
wnwwwwnwwwenwnwswnwwnwwwswneww
nwneeeeeesenenweeeeeseeneesewe
nwnwnwnwnwnwenwwnwnwnwnwsenwnwnwnwnww
eseesewsewneeseneswneseneseesew
wseswenwnenewnwwswwewsesewwwsee
wsweseswsenwnwnwesesewseneseseseseese
wseswswseneneewswseseseseseswswsesese
swseswneswseseswseeswseswwswwswewswne
esweeeneeeeeseneeeeenwwee
wswswewnwswswswswnwswswswswe
nwweneswewwneneeeeneeweeeeee
sesesesenweswseseenwseseeeswsenwsese
neesewsenenweswsw
wswwswwseswweswswwwwnewwwwsww
swneswswswswswswswswnewswswseswswswswswsw
eweswnwnwwewswwswswswwswwswnwwswsw
nwsesesesweseseseseseseenwewnesenwsesesw
wwswswswewweswswswwwenewswwsww
seeeeweeeeeesweseeneeeee
esweeeseseeeseweseneseeeeese
wwswweswwwswswswwswwwwswww
neswseneseewnweenwnenenwneseswenwenwse
esenweeeseeeeswnwesweenwsenwe
swnwsenwnwnwnwnenwnwenwsenwwnenenw
swnwsenwnwsewsenwnenwnwnwnwe
neneweesweneneewenenewwsesew
nwnwwnwnwnwnwwnwwwewswnwnwnwnw
nwwnwwswwwnwenwwwnwnwwenwnwwnwnwnw
wseseswneeneweseseswswswsenwnwsesew
wwswswwwwswswwwnwswewswwwwne
eeeeeeeeesweeenweee
ewnwnwnwnwwnwnwseswnwnwnwenwsenwnwnw
nwnenweswnenwnwswenenwswnwesenwnesw
nwwnwwnwnesesenwsenwnwnwneenwenwswnw
senwneneweswenwswnwnwwwnwwsenwnwne
eseeswseeeenwsenwe
sewsesweseseeesenweseeneseseseseese
nenwnenesesenwneneesweneeenewnenee
seswswswswwwswwwnewwswwwwwww
swswwswnwswswneswwwswewswswswsewsw
nwwwswnwenwswnwsenwnwwwwewnwseneene
swwwneswnwewnwwwseswwwseswwsw
nwwenwnwnwsewnwwwnwnewnwwwwnwnwew
nwsenwsenewenwnwnewnwnwsenwswnwnwnwwnw
seswseseseswseswseseseeseesesesenwsewsenw
neswnwswnwewswswswwewnewwesweww
nwnenwnenwnenwnwnwnenwsenenwsenwnwnwnenwne
seswswwwnwwswwwswwnwswnewwwewww
nenenenenenenenenenenenwswnenenenenenenesew
neswswswswswswswswswswswswswenwswswswsw
sesweeeneeseesweeneeeeee
nwwswwswswwneenwswwneswnwswswswee
sewseesesenwseseseseesesesesesw
neenenesweweenweeeneneneswe
nwwwwneswwwwwsewwnenwswwnewwnw
eeeswnenweeeswswneeeneneswneene
sewnwnwseneneswneseswsesewswnwsww
enwnwswnenwswwsenwsenwnwnenwnwnwswnenwnw
neeeswneeeenwnewnweneeneneeseese
swsesewnwswnesewwwwswwwwwwneww
swswswwswswseswneswwwwswswswwsw
sewnewwwwwnewwwwwwswswwww
nenwenwnwneneswenwseseeeewneswnee
swwewnwwwnwsesenenesenwsweneswnenwnww
eeeseeneeeeeeweneeeeeene
swseseeswseswnwswsewswneseseswsesesese
nwseeweweneenweseeesweeeee
eeeeeneneneneneneeneeswwnewne
wwwwsewsweswswweswswnwwwswswswsw
nwswnwnenwwnwwnwnwnw
eeesenweeeseeeenwsweeesesese
enwnwseenwnwnwnwnwnwnwnenwnenenenwwnwsw
sewswswnewneswswneswswswseswswswswswswswsw
nwnenwnenwnwnwnenwnwnwnwnenwnwsenwnwnw
nwswswneswswwwswneeswwnenwnewwswswsese
sweswneswswwwswswswswwwswswswswswsw
wnwnwenwnewnwswwnwwswwwnwwenwese
swseneswswswswwswswswswneswswswswswswswsw
nwseeswnwnwsenwwswnwseenwnenwnwwe
wwwsewwnwwnewnwwwwwwwwww
sesweseeseeeseeseneenenwsewswsesese
wnwswnwwnwnwwnwwnwwnwnwnewswnenewsw
nenwnwnwnwnwnenwsenwnwnwnwnwnwnwnwnwnww
wnwnenwswnwwwnwwesesew
nwnenenenwnenenenwswnwnenwnenwneenwnene
eswnwwswswseseswswnwseswneswswsw
nwnwnenwwnenesenwnenenwnwneenenww
nwwwneneneenenwnwnenwneswneneneeneene
seseneneswwnwenewwswenewsenesewesww
neenewnenewneneneneseneneeeneneene
wwwwnenwwwnwwwwnwwwwsewwew
neswnwswnwseeseeswnweseneenwsesenew
nwnenwneenwnwnenwnwnenwswnwnenwnenwswnwnwe
nenewseswwwswswswswswswse
seswsenesesesewseswneswseeseseswseseswnw
wnwsewseswsewwwwnwwwwwwwenw
swwswwswswswsweeswswswswswswww
swnwnwnwnwwnwnwnwwwnwnwnwnwenwwnewsw
wweeneeeswneeeeeese
swswswswswswswwneneswswswswwswswswwswsesw
seseseneswseseseseswseswseseseseswwsenwsese
wwwewswnwwwwwnwwnwswnwne
wenwnwwwnwwwswwnwwwnewnewswsenw
swwswwwnenesewswswswnwswswsewwwwsw
nenwnewneneneseneswneneneneenwenenenene
nenenewneneneswnenenenenenenenenenesene
swnwwsewwwwwwwwswwneswwesesw
wwnwnwnwwwsewwwwwwwwwwsew
nenenesenewnenwneswnenwseeenwnenwsee
senwenenwnwnenwnwnenwnwneneneswnwnwnesene
neneenwneneneweeseswwnesenenwnwnewnesw
ewnwnenwnenwnenenwnenwsenwnwneswnwsenw
seswswsweseseneswnesesenwswnwseseswswwsese
swswnwswenenwsewsesw
sesweeseeneseseswsewesenenwnwsw
seseseswseseeswweseswseswnwsesesesesw
neeswnwswnenesesenwnwnwewsenwnwnewwsese
wneswwwwwwwswwswwswswswww
eeeeeeneneeenwswnewsweswnwnenw
neneswweeneeenwwseneswnweneenee
nenenewnwnenwnenewneneeneneneene
wswswswseswswsenenwswseswsweswsweswswnwsw
wsesesesesesesesesesesesesesesenesesese
wnwwnwwwnwswnwwsenwnwenwnewnwwnw
wwswneneesewseneswnenenenenenenenwneese
neeseswnenenwwnenenwseneneneenwneneww
enwnenwswneneneneneswenenwnenenenenenenwne
neneneneneneneenenesenenwneeneswnenenene
swsenewswsweseswswswewneewwswwnw
wsewswswnwneswwwwswswwswwwwwww
seneneneneeneneswsenenewnwnwnene
nenewnenenenwnenenwnenenwnenwnenenenese
seseseswswnenwseseseenwswnwswsesesewsese
swnwnwnewsweseeneseswneeenw
wwsenwnwnwnwewwwnwwwnwnwwwnwnw
nwwnwneseseeneswnwnwnenwnwsenwnwswse
eeseneeeseeeeseneseswweseeeswe
swswneseswseswwswswswswwswswswswswnenwsw
nwnwnwnenwwsenenenenwnwswnenwnwenwnwnwnw
eseseseeesesesesenwseseswseesenwsese
enweeseeeswenwseseeeseeeeeesw
sesenweeeeseseeeesweseeseeee
nwnwnwnwnwnwnwsenwnwnwnwnw
nenwneswnwnwnenwnwnwnenwnwnene
neseeeeswwenweeweweweenewe
neweeeseeseseseseeswenweeesenee
swwswnewseeswneneeseenwnwenwnenenenw
seswesenesewswenweseenweeweeene
seesewnwswseseesee
nwneswseseesewwnwseesenewneseswsese
nwseeeeenwesesewneseseeseeswsesee
nenenenewneseesenenweeesenenwnenenene
eeenwswwnwneenweeewsenwswesese
wneswwwwwswwwnewswswswwwswwseswsw
swseswseseswsesenwsesesenesesesweswseswse
wwswneswwsewwwweswsw
wseeseeenwseseneswswseese
nenwswnwswwwswsee
nwnwnwnenwnwnwnwnwnewnwnwnwswneenenenwne
eeeeswneseeeesesee
enenenwnwnwnwnenenenwnwnwnwswnenwnwswnw
eenewesesenenenenenewnenenenwneswnene
nwnwnwnwsenwnwesewnwsenenwwwwwnwsenwne
eesenwwsenwseswswwseweeeesenene
eeeneneeneeneeeeeneeewseesw
swwwwwswswswswwwswnwswwswwsweesw
neneneeenenewesweenwneeseeenenwee
swwswnwwswswswwswewswwwswswwww
neneneneneeewneeweneneenene
swswseswswnwswswsweseswswswwswswswswswsee
nwnwneswswswsewneswswseswnweswswweswse
eswswwswswswswswwneswswsweswsw
nwwwswswswwwsenwwwwnesewwswww
newneneeswneneneenesenenesw
nwwnwnwenwnwnwwnwww
nenesesewseseseseseseseseseseseseseesewe
neneneneneneneneneneeswneneswnenwneenene
nwswnwnwwwwnwnwnwewnwnww
nwnwnenwnwnwnwnwnenwnwsenwwnwnwnwnwswnwnw
nwnwnwnenewsenenenenwnenwewwsenenwne
wwsweswwwwswwswwswswsww
newseenewenwseswswsw
neswsenwnwnweenenwesenenwnesenenenenenesw
nwswwnwwenwnwnwnwnwenwnwswnwnwwnwwnw
nenwneswnenwswnenwnenenwnwnenenenenene
swswswswwweswswnwswseswswnewsweswswsw
ewseeseseseseeseeesenwseseseesese
nwnewnwsenwwnwwsenwnwww
nwswswswweneswswwswwneseswseswswswe
eewseweneeeseesweneesesenwneswe
wswwnesewnewwneneswsewwwwsewwww
nenenenwnenwnenwnenwenwnewneswnwnwnee
eeweeeeesesewnewseenweseee
enenenewswnenenwseneneeneneenenenenenee
eswenwswnwnwnenewswwneseseseeesenw
swswseswswswswseseswneswsw
neneeenwswnesweswneseneneenenweeenene
newwwwesewsewwwwwwnwswwneww
wesenenwnweseeseseeeeswe
seeeenweneneeneeeeeeene
swwsewnwseseneweneswneeswswnwseswswse
wnenenwswneenewneswneneneeeswenwne
sewnesenwwnwnwnwwnewnwnwnwnwswsewnw
eeeenwswesweeswneeweeeeenee
nwseswswsesesenwseseseswswsw
eeeseseeseesesewnenwewesweweee
wswsewwwsenwnenewsewwsenwnewwnew
eeeeenwneeeenwenesesweeeneeee
nesewseswneneenenwnene
neneenwneneneswsweenewnenwneneenene
nwnwnwnwnwnwwnwnwnwweswnwnwnwnwnwwenw
seswsweseswseswswseneswswwswseseswswsw
seseseswwseseswswswseneenewsew
swsewswswsesesewswseseswswneswnesw
ewweenwneseneeneesweeeweee
swseswswseswsweswneswswswsenwswsw
neseswseseseseseesesenwwseseesesese
nwswnwswnwnwnwwnwenwnwnwenwnwnwnwnenww
neneneneneenesweseenewnewneeswnesee
sweseseeewwneswseenweesesewnwe
nwnwnwnwewnwnwnwnwnwnwwnwwnwwsenwenw
nwwwwswswswwewwsenwww
eswwnwnwneswswswnwwswswweseswwswswsw
swneweseneenenwneneneeseneseweww
nwnenenwnwnenwnenenenwnenwnwnwsenwne
neswswswswswnwsesenenewwseseseswseswse
nesenwswseseseseewsesesweswesenwsesew
nwwnwnwnwnwsenwnweswnwwswnwnwnwnwenenw
nwneneeswnenwnwnenwwnwnwenwneswnwnwsw
nwnenwnwswnenenwnewnwnwnweweswnwswseswe
wnwsenewswnwnwnwnwwnwnwswnwnwswnwenwnwe
swwswswswswswswswswswneseswswswswswswsw
enwesenwseneesewwnwswse
neeneenewenesesweneneeeeneeene
esewesenwnenewneewnenene
nenenenenewneneneneenwnwneneneneneswe
seenweeseeseseesesesee
