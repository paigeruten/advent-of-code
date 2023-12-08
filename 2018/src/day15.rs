use std::cmp;
use std::cmp::Ordering;
use std::fmt;
use std::collections::HashMap;
use std::collections::HashSet;
use std::fmt::Display;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::ops::Add;
use std::str::FromStr;

const DEFAULT_HEALTH: i32 = 200;
const DEFAULT_ATTACK: i32 = 3;

const DIRECTIONS: [(isize, isize); 4] = [(0, 1), (1, 0), (0, -1), (-1, 0)];

#[derive(PartialEq, Debug, Clone, Copy, Eq, Hash)]
struct Position(usize, usize);

impl Position {
  pub fn x(self) -> usize {
    return self.0;
  }

  pub fn y(self) -> usize {
    return self.1;
  }
}

impl Add<(isize, isize)> for Position {
  type Output = Position;

  fn add(self, (dx, dy): (isize, isize)) -> Position {
    Position(
      (self.x() as isize + dx) as usize,
      (self.y() as isize + dy) as usize,
    )
  }
}

#[derive(PartialEq, Debug, Clone, Copy)]
enum Tile {
  Empty,
  Wall,
  Elf,
  Goblin,
}

impl Tile {
  pub fn from_char(c: char) -> Option<Tile> {
    use self::Tile::*;

    Some(match c {
      '.' => Empty,
      '#' => Wall,
      'E' => Elf,
      'G' => Goblin,
       _  => return None,
    })
  }

  pub fn to_char(self) -> char {
    use self::Tile::*;

    match self {
      Empty  => '.',
      Wall   => '#',
      Elf    => 'E',
      Goblin => 'G',
    }
  }
}

#[derive(PartialEq, Debug, Clone, Copy)]
enum Team {
  Elf,
  Goblin,
}

impl Team {
  pub fn enemy(self) -> Team {
    use self::Team::*;

    match self {
      Elf => Goblin,
      Goblin => Elf,
    }
  }

  pub fn tile(self) -> Tile {
    match self {
      Team::Elf => Tile::Elf,
      Team::Goblin => Tile::Goblin,
    }
  }
}

#[derive(Debug)]
struct Unit {
  team: Team,
  position: Position,
  health: i32,
  attack: i32,
}

impl Unit {
  pub fn new(team: Team, position: Position) -> Unit {
    Unit { team, position, health: DEFAULT_HEALTH, attack: DEFAULT_ATTACK }
  }

  pub fn team(&self) -> Team {
    self.team
  }

  pub fn position(&self) -> Position {
    self.position
  }

  pub fn set_position(&mut self, position: Position) {
    self.position = position;
  }

  pub fn health(&self) -> i32 {
    self.health
  }

  pub fn is_alive(&self) -> bool {
    self.health > 0
  }

  pub fn take_damage(&mut self, damage: i32) {
    self.health -= damage;
  }

  pub fn attack_power(&self) -> i32 {
    self.attack
  }

  pub fn set_attack_power(&mut self, attack_power: i32) {
    self.attack = attack_power;
  }
}

#[derive(PartialEq)]
enum LogLevel {
  None,
  Round,
  Turn,
}

struct World {
  tiles: Vec<Tile>,
  width: usize,
  height: usize,
  units: Vec<Unit>,
  rounds_completed: i32,
  log_level: LogLevel,
}

impl World {
  pub fn tile(&self, position: Position) -> Option<Tile> {
    if position.x() >= self.width || position.y() >= self.height {
      return None;
    }

    Some(self.tiles[position.y() * self.width + position.x()])
  }

  pub fn set_tile(&mut self, position: Position, tile: Tile) -> Option<()> {
    if position.x() >= self.width || position.y() >= self.height {
      return None;
    }

    self.tiles[position.y() * self.width + position.x()] = tile;

    Some(())
  }

  pub fn set_elf_attack_power(&mut self, attack_power: i32) {
    for unit in self.units.iter_mut() {
      if unit.team() == Team::Elf {
        unit.set_attack_power(attack_power);
      }
    }
  }

  pub fn set_log_level(&mut self, log_level: LogLevel) {
    self.log_level = log_level;
  }

  pub fn num_dead(&self, team: Team) -> usize {
    self.units.iter()
      .filter(|unit| !unit.is_alive() && unit.team() == team)
      .count()
  }

  pub fn combat(&mut self) -> i32 {
    let delay = std::time::Duration::from_millis(100);

    if self.log_level == LogLevel::Round || self.log_level == LogLevel::Turn {
      println!("Initial map:\n\n{}\n", self);
      std::thread::sleep(delay);
    }

    loop {
      if self.round().is_none() {
        if self.log_level == LogLevel::Round || self.log_level == LogLevel::Turn {
          println!("Combat end:\n\n{}\n", self);
        }

        return self.rounds_completed * self.total_health();
      }

      self.rounds_completed += 1;

      if self.log_level == LogLevel::Round {
        println!("After {} rounds:\n\n{}\n", self.rounds_completed, self);
        std::thread::sleep(delay);
      }
    }
  }

  pub fn round(&mut self) -> Option<()> {
    let delay = std::time::Duration::from_millis(50);

    let mut units_with_indexes = self.units.iter()
      .enumerate()
      .collect::<Vec<(usize, &Unit)>>();

    units_with_indexes.sort_by_key(|(_, unit)| (
      unit.position.y(),
      unit.position.x(),
    ));

    let unit_indexes = units_with_indexes.into_iter()
      .map(|(i, _)| i)
      .collect::<Vec<usize>>();

    for unit_index in unit_indexes {
      if self.units[unit_index].is_alive() {
        self.turn(unit_index)?;

        if self.log_level == LogLevel::Turn {
          println!("Round {}, unit #{}'s turn:\n\n{}\n", self.rounds_completed + 1, unit_index, self);
          std::thread::sleep(delay);
        }
      }
    }

    Some(())
  }

  pub fn turn(&mut self, unit_index: usize) -> Option<()> {
    assert!(self.units[unit_index].is_alive());

    let enemy_team = self.units[unit_index].team().enemy();
    let any_enemies_alive = self.units.iter()
      .any(|unit| unit.is_alive() && unit.team() == enemy_team);

    if !any_enemies_alive {
      return None;
    }

    self.move_step(unit_index);
    self.attack_step(unit_index);

    Some(())
  }

  pub fn move_step(&mut self, unit_index: usize) -> Option<()> {
    assert!(self.units[unit_index].is_alive());

    let position = self.units[unit_index].position();
    let team = self.units[unit_index].team();
    let enemy_team = team.enemy();

    for &direction in &DIRECTIONS {
      if self.tile(position + direction) == Some(enemy_team.tile()) {
        return None;
      }
    }

    let destination = self.distances_from(position)
      .into_iter()
      .filter(|&(position, _)| {
        for &direction in &DIRECTIONS {
          if self.tile(position + direction) == Some(enemy_team.tile()) {
            return true;
          }
        }
        false
      })
      .min_by_key(|&(position, distance)|
        (distance, position.y(), position.x())
      )?
      .0;

    let distances_from_destination = self.distances_from(destination);

    let new_position = DIRECTIONS.iter()
      .map(|&direction| position + direction)
      .filter(|&new_position| self.tile(new_position) == Some(Tile::Empty))
      .min_by_key(|new_position| (
        distances_from_destination.get(new_position).unwrap_or(&std::usize::MAX),
        new_position.y(),
        new_position.x()
      ))
      .unwrap();

    if !distances_from_destination.contains_key(&new_position) {
      return None;
    }

    self.set_tile(position, Tile::Empty);
    self.set_tile(new_position, team.tile());

    self.units[unit_index].set_position(new_position);

    Some(())
  }

  pub fn attack_step(&mut self, unit_index: usize) -> Option<()> {
    assert!(self.units[unit_index].is_alive());

    let position = self.units[unit_index].position();
    let attack_power = self.units[unit_index].attack_power();
    let team = self.units[unit_index].team();
    let enemy_team = team.enemy();

    let target_index = DIRECTIONS.iter()
      .filter_map(|&direction| self.units.iter().position(|unit| {
        unit.is_alive() &&
        unit.team() == enemy_team &&
        unit.position() == position + direction
      }))
      .min_by_key(|&enemy_index| {
        let enemy = &self.units[enemy_index];
        (enemy.health(), enemy.position.y(), enemy.position.x())
      })?;

    let enemy = &mut self.units[target_index];
    enemy.take_damage(attack_power);

    if !enemy.is_alive() {
      let enemy_position = enemy.position();
      self.set_tile(enemy_position, Tile::Empty);
    }

    Some(())
  }

  pub fn distances_from(&self, source: Position) -> HashMap<Position, usize> {
    let mut distances = HashMap::new();
    let mut unvisited = HashSet::new();

    for tile_x in 0..self.width {
      for tile_y in 0..self.height {
        let pos = Position(tile_x, tile_y);
        if self.tile(pos) == Some(Tile::Empty) {
          unvisited.insert(pos);
        }
      }
    }

    distances.insert(source, 0);

    let mut current = source;
    loop {
      let next_distance = distances[&current] + 1;

      for &direction in &DIRECTIONS {
        let neighbor = current + direction;

        if self.tile(neighbor) == Some(Tile::Empty) {
          let neighbor_distance = distances.entry(neighbor).or_insert(next_distance);
          *neighbor_distance = cmp::min(*neighbor_distance, next_distance);
        }
      }

      unvisited.remove(&current);

      match unvisited.iter().min_by(|a, b| {
        // None = infinity!
        match (distances.get(a), distances.get(b)) {
          (Some(a), Some(b)) => a.cmp(b),
          (Some(_), None)    => Ordering::Less,
          (None, Some(_))    => Ordering::Greater,
          (None, None)       => Ordering::Equal,
        }
      }) {
        Some(&next) if distances.contains_key(&next) => {
          current = next;
        },
        _ => break,
      };
    }

    distances
  }

  fn total_health(&self) -> i32 {
    self.units.iter()
      .filter(|unit| unit.is_alive())
      .map(|unit| unit.health())
      .sum()
  }
}

impl FromStr for World {
  type Err = &'static str;

  fn from_str(s: &str) -> Result<World, Self::Err> {
    let width = s.lines().next().unwrap().len();
    let mut tiles = Vec::new();
    let mut units = Vec::new();

    let mut x = 0;
    let mut y = 0;
    for c in s.chars() {
      if let Some(tile) = Tile::from_char(c) {
        tiles.push(tile);

        match tile {
          Tile::Elf    => units.push(Unit::new(Team::Elf, Position(x, y))),
          Tile::Goblin => units.push(Unit::new(Team::Goblin, Position(x, y))),
          _ => (),
        };

        x += 1;
      } else if c == '\n' {
        y += 1;
        x = 0;
      }
    }

    let height = y + 1;

    if tiles.len() != width * height {
      return Err("invalid world map string");
    }

    Ok(World {
      tiles,
      width,
      height,
      units,
      rounds_completed: 0,
      log_level: LogLevel::None
    })
  }
}

impl Display for World {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    for y in 0..self.height {
      let row = self.tiles[y * self.width .. (y+1) * self.width]
        .iter()
        .map(|tile| tile.to_char())
        .collect::<String>();

      write!(f, "{}", row)?;

      let mut units = self.units.iter()
        .filter(|unit| unit.position().y() == y && unit.is_alive())
        .collect::<Vec<_>>();

      units.sort_by_key(|unit| unit.position().x());

      for (index, unit) in units.iter().enumerate() {
        write!(f, "{}{}({})",
          if index == 0 { "   " } else { ", " },
          match unit.team() { Team::Elf => "E", Team::Goblin => "G" },
          unit.health())?;
      }

      if y != self.height - 1 {
        write!(f, "\n")?;
      }
    }

    Ok(())
  }
}

fn find_minimum_elf_attack_power(map: &str) -> (i32, i32) {
  for attack_power in 3.. {
    let mut world: World = map.trim().parse().unwrap();
    world.set_elf_attack_power(attack_power);

    let outcome = world.combat();

    if world.num_dead(Team::Elf) == 0 {
      return (attack_power, outcome);
    }
  }

  unreachable!()
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);

  let mut map = String::new();
  reader.read_to_string(&mut map).unwrap();

  println!("What do you want to do?");
  println!("  (1) Solve part 1");
  println!("  (2) Solve part 2");
  println!("  (3) Visualize round-by-round");
  println!("  (4) Visualize turn-by-turn");
  println!("");
  print!("[1-4]? ");
  std::io::stdout().flush().unwrap();

  let mut choice = String::new();
  std::io::stdin().read_line(&mut choice).unwrap();
  let choice = choice.trim().parse::<u32>().expect("integer input expected");

  match choice {
    1 => {
      let mut world: World = map.trim().parse().unwrap();

      println!("\nInitial world:\n\n{}", world);

      let outcome = world.combat();

      println!("\nAfter combat:\n\n{}", world);

      println!("\nOutcome: {}", outcome);
      println!("Dead elves: {}", world.num_dead(Team::Elf));
      println!("Dead goblins: {}", world.num_dead(Team::Goblin));
    },
    2 => {
      println!("\nFinding minimum attack power needed for no elves to die...");

      let (attack_power, outcome) = find_minimum_elf_attack_power(&map);

      println!("Attack power: {}", attack_power);
      println!("Outcome: {}", outcome);
    },
    3 | 4 => {
      let mut world: World = map.trim().parse().unwrap();

      world.set_log_level(match choice {
        3 => LogLevel::Round,
        4 => LogLevel::Turn,
        _ => unreachable!(),
      });

      world.combat();
    },
    _ => {
      println!("That wasn't one of the choices!");
    },
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_parse_world() {
    let map = "
#######
#E..G.#
#...#.#
#.G.#G#
#######
";

    let world: World = map.trim().parse().unwrap();

    assert_eq!(world.tile(Position(1, 3)), Some(Tile::Empty));
    assert_eq!(world.tile(Position(0, 0)), Some(Tile::Wall));
    assert_eq!(world.tile(Position(6, 4)), Some(Tile::Wall));
    assert_eq!(world.tile(Position(1, 1)), Some(Tile::Elf));
    assert_eq!(world.tile(Position(5, 3)), Some(Tile::Goblin));
    assert_eq!(world.tile(Position(7, 3)), None);
    assert_eq!(world.tile(Position(0, 5)), None);

    let expected = "
#######
#E..G.#   E(200), G(200)
#...#.#
#.G.#G#   G(200), G(200)
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_distances_from() {
    let map = "
#######
#.E...#
#.....#
#...G.#
#######
";

    let world: World = map.trim().parse().unwrap();

    let distances = world.distances_from(Position(4, 2));

    assert_eq!(13, distances.len());

    assert_eq!(4, distances[&Position(1, 1)]);
    assert_eq!(2, distances[&Position(3, 1)]);
    assert_eq!(1, distances[&Position(4, 1)]);
    assert_eq!(2, distances[&Position(5, 1)]);
    assert_eq!(3, distances[&Position(1, 2)]);
    assert_eq!(2, distances[&Position(2, 2)]);
    assert_eq!(1, distances[&Position(3, 2)]);
    assert_eq!(0, distances[&Position(4, 2)]);
    assert_eq!(1, distances[&Position(5, 2)]);
    assert_eq!(4, distances[&Position(1, 3)]);
    assert_eq!(3, distances[&Position(2, 3)]);
    assert_eq!(2, distances[&Position(3, 3)]);
    assert_eq!(2, distances[&Position(5, 3)]);
  }

  #[test]
  fn test_distances_from_with_unreachable_tiles() {
    let map = "
#######
#E..G.#
#...#.#
#.G.#G#
#######
";

    let world: World = map.trim().parse().unwrap();

    let distances = world.distances_from(Position(1, 1));

    assert_eq!(8, distances.len());

    assert_eq!(0, distances[&Position(1, 1)]);
    assert_eq!(1, distances[&Position(2, 1)]);
    assert_eq!(2, distances[&Position(3, 1)]);
    assert_eq!(1, distances[&Position(1, 2)]);
    assert_eq!(2, distances[&Position(2, 2)]);
    assert_eq!(3, distances[&Position(3, 2)]);
    assert_eq!(2, distances[&Position(1, 3)]);
    assert_eq!(4, distances[&Position(3, 3)]);
  }

  #[test]
  fn test_move_step() {
    let map = "
#######
#.E...#
#.....#
#...G.#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.move_step(0);

    let expected = "
#######
#..E..#   E(200)
#.....#
#...G.#   G(200)
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_move_step_with_unreachable_tiles() {
    let map = "
#######
#E..G.#
#...#.#
#.G.#G#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.move_step(0);

    let expected = "
#######
#.E.G.#   E(200), G(200)
#...#.#
#.G.#G#   G(200), G(200)
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_attack_step() {
    let map = "
#######
#G....#
#..G..#
#..EGE#
#..G..#
#...G.#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.attack_step(2);

    let expected = "
#######
#G....#   G(200)
#..G..#   G(197)
#..EGE#   E(200), G(200), E(200)
#..G..#   G(200)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.attack_step(4);

    let expected = "
#######
#G....#   G(200)
#..G..#   G(197)
#..EGE#   E(200), G(197), E(200)
#..G..#   G(200)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    for _ in 0..66 {
      world.attack_step(2);
    }

    let expected = "
#######
#G....#   G(200)
#.....#
#..EGE#   E(200), G(197), E(200)
#..G..#   G(200)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    for _ in 0..100 {
      world.attack_step(4);
    }

    let expected = "
#######
#G....#   G(200)
#.....#
#..E.E#   E(200), E(200)
#..G..#   G(200)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.attack_step(2);

    let expected = "
#######
#G....#   G(200)
#.....#
#..E.E#   E(200), E(200)
#..G..#   G(197)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.attack_step(5);

    let expected = "
#######
#G....#   G(200)
#.....#
#..E.E#   E(197), E(200)
#..G..#   G(197)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_turn_do_nothing() {
    let map = "
#######
#.E..E#
#...#.#
#...#G#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.turn(0);

    let expected = "
#######
#.E..E#   E(200), E(200)
#...#.#
#...#G#   G(200)
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_turn_move_without_attacking() {
    let map = "
#######
#.....#
#.E..G#
#.....#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.turn(0);

    let expected = "
#######
#.....#
#..E.G#   E(200), G(200)
#.....#
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_turn_attack_without_moving() {
    let map = "
#######
#.....#
#.EG..#
#.....#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.turn(0);

    let expected = "
#######
#.....#
#.EG..#   E(200), G(197)
#.....#
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_turn_move_and_attack() {
    let map = "
#######
#.....#
#.E.G.#
#.....#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    world.turn(0);

    let expected = "
#######
#.....#
#..EG.#   E(200), G(197)
#.....#
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_round() {
    let map = "
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    let expected = "
#######
#.G...#   G(200)
#...EG#   E(200), G(200)
#.#.#G#   G(200)
#..G#E#   G(200), E(200)
#.....#
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#..G..#   G(200)
#...EG#   E(197), G(197)
#.#G#G#   G(200), G(197)
#...#E#   E(197)
#.....#
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#...G.#   G(200)
#..GEG#   G(200), E(188), G(194)
#.#.#G#   G(194)
#...#E#   E(194)
#.....#
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    for _ in 0..21 {
      world.round();
    }

    let expected = "
#######
#...G.#   G(200)
#..G.G#   G(200), G(131)
#.#.#G#   G(131)
#...#E#   E(131)
#.....#
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#..G..#   G(200)
#...G.#   G(131)
#.#G#G#   G(200), G(128)
#...#E#   E(128)
#.....#
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#.G...#   G(200)
#..G..#   G(131)
#.#.#G#   G(125)
#..G#E#   G(200), E(125)
#.....#
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#G....#   G(200)
#.G...#   G(131)
#.#.#G#   G(122)
#...#E#   E(122)
#..G..#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#G....#   G(200)
#.G...#   G(131)
#.#.#G#   G(119)
#...#E#   E(119)
#...G.#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    world.round();

    let expected = "
#######
#G....#   G(200)
#.G...#   G(131)
#.#.#G#   G(116)
#...#E#   E(113)
#....G#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));

    for _ in 0..19 {
      world.round();
    }

    let expected = "
#######
#G....#   G(200)
#.G...#   G(131)
#.#.#G#   G(59)
#...#.#
#....G#   G(200)
#######
";
    assert_eq!(expected.trim(), format!("{}", world));
  }

  #[test]
  fn test_combat1() {
    let map = "
#######
#G..#E#
#E#E.E#
#G.##.#
#...#E#
#...E.#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    let outcome = world.combat();

    let expected = "
#######
#...#E#   E(200)
#E#...#   E(197)
#.E##.#   E(185)
#E..#E#   E(200), E(200)
#.....#
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
    assert_eq!(36334, outcome);
  }

  #[test]
  fn test_combat2() {
    let map = "
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    let outcome = world.combat();

    let expected = "
#######
#.E.E.#   E(164), E(197)
#.#E..#   E(200)
#E.##.#   E(98)
#.E.#.#   E(200)
#...#.#
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
    assert_eq!(39514, outcome);
  }

  #[test]
  fn test_combat3() {
    let map = "
#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    let outcome = world.combat();

    let expected = "
#######
#G.G#.#   G(200), G(98)
#.#G..#   G(200)
#..#..#
#...#G#   G(95)
#...G.#   G(200)
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
    assert_eq!(27755, outcome);
  }

  #[test]
  fn test_combat4() {
    let map = "
#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######
";

    let mut world: World = map.trim().parse().unwrap();

    let outcome = world.combat();

    let expected = "
#######
#.....#
#.#G..#   G(200)
#.###.#
#.#.#.#
#G.G#G#   G(98), G(38), G(200)
#######
";

    assert_eq!(expected.trim(), format!("{}", world));
    assert_eq!(28944, outcome);
  }

  #[test]
  fn test_combat5() {
    let map = "
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
";

    let mut world: World = map.trim().parse().unwrap();

    let outcome = world.combat();

    let expected = "
#########
#.G.....#   G(137)
#G.G#...#   G(200), G(200)
#.G##...#   G(200)
#...##..#
#.G.#...#   G(200)
#.......#
#.......#
#########
";

    assert_eq!(expected.trim(), format!("{}", world));
    assert_eq!(18740, outcome);
  }

  #[test]
  fn test_find_attack_power1() {
    let map = "
#######
#.G...#
#...EG#
#.#.#G#
#..G#E#
#.....#
#######
";

    let (attack_power, outcome) = find_minimum_elf_attack_power(map);

    assert_eq!(15, attack_power);
    assert_eq!(4988, outcome);
  }

  #[test]
  fn test_find_attack_power2() {
    let map = "
#######
#E..EG#
#.#G.E#
#E.##E#
#G..#.#
#..E#.#
#######
";

    let (attack_power, outcome) = find_minimum_elf_attack_power(map);

    assert_eq!(4, attack_power);
    assert_eq!(31284, outcome);
  }

  #[test]
  fn test_find_attack_power3() {
    let map = "
#######
#E.G#.#
#.#G..#
#G.#.G#
#G..#.#
#...E.#
#######
";

    let (attack_power, outcome) = find_minimum_elf_attack_power(map);

    assert_eq!(15, attack_power);
    assert_eq!(3478, outcome);
  }

  #[test]
  fn test_find_attack_power4() {
    let map = "
#######
#.E...#
#.#..G#
#.###.#
#E#G#G#
#...#G#
#######
";

    let (attack_power, outcome) = find_minimum_elf_attack_power(map);

    assert_eq!(12, attack_power);
    assert_eq!(6474, outcome);
  }

  #[test] #[ignore] // slow!
  fn test_find_attack_power5() {
    let map = "
#########
#G......#
#.E.#...#
#..##..G#
#...##..#
#...#...#
#.G...G.#
#.....G.#
#########
";

    let (attack_power, outcome) = find_minimum_elf_attack_power(map);

    assert_eq!(34, attack_power);
    assert_eq!(1140, outcome);
  }
}

