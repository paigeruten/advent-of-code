use std::collections::HashMap;
use std::fmt;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;
use std::thread;
use std::time::Duration;

#[derive(Debug, PartialEq, Clone, Copy, Hash, Eq)]
enum Acre {
  Open,
  Trees,
  Lumberyard,
}

#[derive(Debug, PartialEq, Hash, Eq, Clone)]
struct World {
  map: Vec<Acre>,
  width: usize,
  height: usize,
}

impl World {
  pub fn get_acre(&self, x: usize, y: usize) -> Acre {
    self.map[y * self.width + x]
  }

  pub fn next(&self) -> World {
    let mut next_map = Vec::with_capacity(self.width * self.height);

    for y in 0..self.height {
      for x in 0..self.width {
        let (num_open, num_trees, num_lumberyards) = self.neighbors(x, y);
        let next_acre = match self.get_acre(x, y) {
          Acre::Open => {
            if num_trees >= 3 {
              Acre::Trees
            } else {
              Acre::Open
            }
          },
          Acre::Trees => {
            if num_lumberyards >= 3 {
              Acre::Lumberyard
            } else {
              Acre::Trees
            }
          },
          Acre::Lumberyard => {
            if num_lumberyards > 0 && num_trees > 0 {
              Acre::Lumberyard
            } else {
              Acre::Open
            }
          },
        };
        next_map.push(next_acre);
      }
    }

    World { map: next_map, width: self.width, height: self.height }
  }

  pub fn resource_value(&self) -> usize {
    self.count(Acre::Trees) * self.count(Acre::Lumberyard)
  }

  fn neighbors(&self, from_x: usize, from_y: usize) -> (usize, usize, usize) {
    let mut num_open = 0;
    let mut num_trees = 0;
    let mut num_lumberyards = 0;
    for (dx, dy) in &[(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)] {
      let x = ((from_x as isize) + dx) as usize;
      let y = ((from_y as isize) + dy) as usize;
      if x < self.width && y < self.height {
        match self.get_acre(x, y) {
          Acre::Open       => { num_open += 1; },
          Acre::Trees      => { num_trees += 1; },
          Acre::Lumberyard => { num_lumberyards += 1; },
        }
      }
    }
    (num_open, num_trees, num_lumberyards)
  }

  fn count(&self, acre: Acre) -> usize {
    self.map.iter()
      .filter(|&&a| a == acre)
      .count()
  }
}

impl FromStr for World {
  type Err = ();

  fn from_str(s: &str) -> Result<Self, Self::Err> {
    let mut map = Vec::new();
    let mut width = 0;
    let mut height = 0;

    for (index, ch) in s.chars().enumerate() {
      match ch {
        '.' => map.push(Acre::Open),
        '|' => map.push(Acre::Trees),
        '#' => map.push(Acre::Lumberyard),
        '\n' => {
          if width == 0 {
            width = index;
          }
          height += 1;
        },
        _ => return Err(()),
      };
    }
    height += 1;

    Ok(World { map, width, height })
  }
}

impl fmt::Display for World {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    for y in 0..self.height {
      for x in 0..self.width {
        match self.get_acre(x, y) {
          Acre::Open       => write!(f, "."),
          Acre::Trees      => write!(f, "|"),
          Acre::Lumberyard => write!(f, "#"),
        }?
      }
      write!(f, "\n")?;
    }
    Ok(())
  }
}

fn solve_part1(map: &str) {
  let mut world: World = map.trim().parse().unwrap();

  for _ in 0..10 {
    println!("{}\n", world);
    thread::sleep(Duration::from_millis(50));

    world = world.next();
  }

  println!("{}", world);
  println!("Total resource value: {}", world.resource_value());
}

fn solve_part2(map: &str) {
  let mut seen: HashMap<World, usize> = HashMap::new();
  let mut world: World = map.trim().parse().unwrap();

  for step in 0.. {
    seen.insert(world.clone(), step);
    world = world.next();

    if let Some(past_step) = seen.get(&world) {
      let mut step = step + 1;
      let freq = step - past_step;
      while step + freq <= 1_000_000_000 {
        step += freq;
      }
      while step < 1_000_000_000 {
        world = world.next();
        step += 1;
      }
      break;
    }
  }

  println!("{}", world);
  println!("Total resource value: {}", world.resource_value());
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);
  let mut map = String::new();
  reader.read_to_string(&mut map).unwrap();

  solve_part1(&map);
  solve_part2(&map);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_everything() {
    let map = "
.#.#...|#.
.....#|##|
.|..|...#.
..|#.....#
#.#|||#|#|
...#.||...
.|....|...
||...#|.#|
|.||||..|.
...#.|..|.
";

    let world: World = map.trim().parse().unwrap();

    assert_eq!(world.get_acre(0, 0), Acre::Open);
    assert_eq!(world.get_acre(6, 1), Acre::Trees);
    assert_eq!(world.get_acre(9, 3), Acre::Lumberyard);
    assert_eq!(world.get_acre(5, 9), Acre::Trees);
    assert_eq!(world.get_acre(9, 9), Acre::Open);

    let world = world.next();
    let map = "
.......##.
......|###
.|..|...#.
..|#||...#
..##||.|#|
...#||||..
||...|||..
|||||.||.|
||||||||||
....||..|.
";

    assert_eq!(world, map.trim().parse().unwrap());

    let world = world
      .next()
      .next()
      .next()
      .next()
      .next()
      .next()
      .next()
      .next()
      .next();

    let map = "
.||##.....
||###.....
||##......
|##.....##
|##.....##
|##....##|
||##.####|
||#####|||
||||#|||||
||||||||||
";

    assert_eq!(world, map.trim().parse().unwrap());

    assert_eq!(world.count(Acre::Trees), 37);
    assert_eq!(world.count(Acre::Lumberyard), 31);
  }
}

