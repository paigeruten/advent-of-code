use std::collections::HashMap;
use std::collections::HashSet;
use std::fmt;
use std::fmt::Display;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
enum Pot {
  Plant,
  NoPlant
}

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
struct PotPattern([Pot; 5]);

impl FromStr for PotPattern {
  type Err = &'static str;

  fn from_str(string: &str) -> Result<PotPattern, Self::Err> {
    let pots: Vec<Pot> = string
      .chars()
      .map(|c| match c {
        '#' => Pot::Plant,
        _ => Pot::NoPlant
      })
      .collect();

    Ok(PotPattern([pots[0], pots[1], pots[2], pots[3], pots[4]]))
  }
}

#[derive(Debug, PartialEq)]
struct Generation {
  plants: HashSet<isize>,
  min_index: isize,
  max_index: isize,
}

impl Generation {
  pub fn next_generation(&self, rules: &HashMap<PotPattern, Pot>) -> Generation {
    let mut next_plants = HashSet::new();
    let mut min_index = self.max_index;
    let mut max_index = self.min_index;

    for index in (self.min_index - 2)..=(self.max_index + 2) {
      if *rules.get(&self.pattern_at(index)).unwrap_or(&Pot::NoPlant) == Pot::Plant {
        next_plants.insert(index);
        if index < min_index { min_index = index; }
        if index > max_index { max_index = index; }
      }
    }

    Generation { plants: next_plants, min_index, max_index }
  }

  pub fn sum(&self) -> isize {
    self.plants.iter().sum()
  }

  fn pattern_at(&self, index: isize) -> PotPattern {
    PotPattern([
      self.pot_at(index - 2),
      self.pot_at(index - 1),
      self.pot_at(index),
      self.pot_at(index + 1),
      self.pot_at(index + 2),
    ])
  }

  fn pot_at(&self, index: isize) -> Pot {
    if self.plants.contains(&index) {
      Pot::Plant
    } else {
      Pot::NoPlant
    }
  }
}

impl Display for Generation {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "(idx {}) ", self.min_index)?;
    for index in self.min_index..=self.max_index {
      if self.plants.contains(&index) {
        write!(f, "#")?;
      } else {
        write!(f, ".")?;
      }
    }

    Ok(())
  }
}

impl FromStr for Generation {
  type Err = &'static str;

  fn from_str(string: &str) -> Result<Generation, Self::Err> {
    let mut plants = HashSet::new();
    let mut min_index = string.len() as isize;
    let mut max_index = 0;

    for (index, c) in string.chars().enumerate() {
      let index = index as isize;
      if c == '#' {
        plants.insert(index);
        if index < min_index { min_index = index; }
        if index > max_index { max_index = index; }
      }
    }

    Ok(Generation { plants, min_index, max_index })
  }
}

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);
  let mut lines = reader.lines();

  let initial_state_line = lines.next().expect("expected initial state").unwrap();
  let initial_state: Generation = initial_state_line[15..].parse().unwrap();

  lines.next().expect("expected blank line").unwrap();

  let mut rules: HashMap<PotPattern, Pot> = HashMap::new();
  for line in lines {
    let line = line.unwrap();
    if line.ends_with("=> #") {
      rules.insert(line[..5].parse().unwrap(), Pot::Plant);
    }
  }

  let mut gen = initial_state;
  for i in 0..=200 {
    println!("{}: {} (sum = {})", i, gen, gen.sum());
    gen = gen.next_generation(&rules);
  }

  // Starting from generation 152, there are 8 plants which just each move 1 to
  // the right on each generation thereafter. So the sum of the indexes goes up
  // by 8 each generation.
  //
  // By looking at the above output, I found this formula for getting the sum
  // for any generation #:
  //
  //     sum = generation_num * 8 - 43
  //
  // So the sum for the 50 billionth generation is:
  //
  //     50_000_000_000 * 8 - 43 = 399999999957
  //
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_next_generation() {
    let initial_state: Generation = "#..#.#..##......###...###".parse().unwrap();

    let mut rules: HashMap<PotPattern, Pot> = HashMap::new();
    rules.insert("...##".parse().unwrap(), Pot::Plant);
    rules.insert("..#..".parse().unwrap(), Pot::Plant);
    rules.insert(".#...".parse().unwrap(), Pot::Plant);
    rules.insert(".#.#.".parse().unwrap(), Pot::Plant);
    rules.insert(".#.##".parse().unwrap(), Pot::Plant);
    rules.insert(".##..".parse().unwrap(), Pot::Plant);
    rules.insert(".####".parse().unwrap(), Pot::Plant);
    rules.insert("#.#.#".parse().unwrap(), Pot::Plant);
    rules.insert("#.###".parse().unwrap(), Pot::Plant);
    rules.insert("##.#.".parse().unwrap(), Pot::Plant);
    rules.insert("##.##".parse().unwrap(), Pot::Plant);
    rules.insert("###..".parse().unwrap(), Pot::Plant);
    rules.insert("###.#".parse().unwrap(), Pot::Plant);
    rules.insert("####.".parse().unwrap(), Pot::Plant);

    let next = initial_state.next_generation(&rules);
    assert_eq!(
      format!("{}", next),
      "(idx 0) #...#....#.....#..#..#..#"
    );

    let next = next.next_generation(&rules);
    assert_eq!(
      format!("{}", next),
      "(idx 0) ##..##...##....#..#..#..##"
    );

    let next = next.next_generation(&rules);
    assert_eq!(
      format!("{}", next),
      "(idx -1) #.#...#..#.#....#..#..#...#"
    );

    let next = next.next_generation(&rules);
    assert_eq!(
      format!("{}", next),
      "(idx 0) #.#..#...#.#...#..#..##..##"
    );

    let mut next = next.next_generation(&rules);
    for _ in 0..15 {
      next = next.next_generation(&rules);
    }

    assert_eq!(
      format!("{}", next),
      "(idx -2) #....##....#####...#######....#.#..##"
    );

    assert_eq!(next.sum(), 325);
  }
}

