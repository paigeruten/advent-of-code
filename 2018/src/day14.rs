use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;

struct RecipeSimulation {
  recipes: Vec<u8>,
  elf1: usize,
  elf2: usize
}

impl RecipeSimulation {
  pub fn new(first_recipe: u8, second_recipe: u8) -> RecipeSimulation {
    RecipeSimulation {
      recipes: vec![first_recipe, second_recipe],
      elf1: 0,
      elf2: 1
    }
  }

  pub fn update(&mut self) {
    let sum = self.recipes[self.elf1] + self.recipes[self.elf2];
    if sum < 10 {
      self.recipes.push(sum);
    } else {
      self.recipes.push(1);
      self.recipes.push(sum - 10);
    }

    self.elf1 = (self.elf1 + self.recipes[self.elf1] as usize + 1) % self.recipes.len();
    self.elf2 = (self.elf2 + self.recipes[self.elf2] as usize + 1) % self.recipes.len();
  }

  pub fn solve1(&mut self, n: usize) -> &[u8] {
    while self.recipes.len() < n + 10 {
      self.update();
    }

    &self.recipes[n..n+10]
  }

  pub fn solve2(&mut self, pat: &[u8]) -> usize {
    let mut i = 0;

    loop {
      while self.recipes.len() < i + pat.len() {
        self.update();
      }

      if &self.recipes[i..i+pat.len()] == pat {
        return i;
      }

      i += 1;
    }
  }
}

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let input_line = reader.lines().next().unwrap().unwrap();
  let n: usize = input_line.parse().unwrap();
  let pat: Vec<u8> = input_line.chars().map(|c| c.to_digit(10).unwrap() as u8).collect();

  let mut simulation = RecipeSimulation::new(3, 7);
  let ten_recipes = simulation.solve1(n);

  println!(
    "Ten recipes: {}",
    ten_recipes.iter().map(|x| x.to_string()).collect::<String>()
  );
  println!(
    "Found pattern after this many recipes: {}",
    simulation.solve2(&pat)
  );
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_recipe_simulation_update() {
    let mut simulation = RecipeSimulation::new(3, 7);
    assert_eq!(simulation.recipes, &[3, 7]);

    simulation.update();
    assert_eq!(simulation.recipes, &[3, 7, 1, 0]);

    simulation.update();
    assert_eq!(simulation.recipes, &[3, 7, 1, 0, 1, 0]);

    simulation.update();
    assert_eq!(simulation.recipes, &[3, 7, 1, 0, 1, 0, 1]);
  }

  #[test]
  fn test_recipe_simulation_solve1() {
    let mut simulation = RecipeSimulation::new(3, 7);

    assert_eq!(
      simulation.solve1(5),
      &[0, 1, 2, 4, 5, 1, 5, 8, 9, 1]
    );
    assert_eq!(
      simulation.solve1(9),
      &[5, 1, 5, 8, 9, 1, 6, 7, 7, 9]
    );
    assert_eq!(
      simulation.solve1(18),
      &[9, 2, 5, 1, 0, 7, 1, 0, 8, 5]
    );
    assert_eq!(
      simulation.solve1(2018),
      &[5, 9, 4, 1, 4, 2, 9, 8, 8, 2]
    );
  }

  #[test]
  fn test_recipe_simulation_solve2() {
    let mut simulation = RecipeSimulation::new(3, 7);

    assert_eq!(
      simulation.solve2(&[0, 1, 2, 4, 5]),
      5
    );
    assert_eq!(
      simulation.solve2(&[5, 1, 5, 8, 9]),
      9
    );
    assert_eq!(
      simulation.solve2(&[9, 2, 5, 1, 0]),
      18
    );
    assert_eq!(
      simulation.solve2(&[5, 9, 4, 1, 4]),
      2018
    );
  }
}

