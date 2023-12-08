use std::io::BufReader;
use std::io::prelude::*;
use std::fs::File;

struct Marble {
  value: usize,
  next: usize,
  prev: usize,
}

struct MarbleCircle {
  marbles: Vec<Marble>,
  current: usize,
}

impl MarbleCircle {
  pub fn new() -> MarbleCircle {
    MarbleCircle {
      marbles: vec![Marble { value: 0, next: 0, prev: 0 }],
      current: 0,
    }
  }

  pub fn current_value(&self) -> usize {
    self.marbles[self.current].value
  }

  pub fn insert_after_current(&mut self, value: usize) {
    let next = self.marbles[self.current].next;

    self.marbles.push(Marble { value, next, prev: self.current });
    let index = self.marbles.len() - 1;

    self.marbles[next].prev = index;
    self.marbles[self.current].next = index;

    self.current = index;
  }

  pub fn remove_current(&mut self) {
    let next = self.marbles[self.current].next;
    let prev = self.marbles[self.current].prev;

    self.marbles[next].prev = prev;
    self.marbles[prev].next = next;

    self.current = next;
  }

  pub fn move_left(&mut self, distance: usize) {
    for _ in 0..distance {
      self.current = self.marbles[self.current].prev;
    }
  }

  pub fn move_right(&mut self, distance: usize) {
    for _ in 0..distance {
      self.current = self.marbles[self.current].next;
    }
  }

  #[allow(dead_code)]
  pub fn to_vec(&self) -> Vec<usize> {
    let mut values = Vec::new();

    let mut marble = &self.marbles[self.current];
    values.push(marble.value);

    while marble.next != self.current {
      marble = &self.marbles[marble.next];
      values.push(marble.value);
    }

    values
  }
}

fn high_score(num_players: usize, last_marble: usize) -> usize {
  let mut circle = MarbleCircle::new();
  let mut scores: Vec<usize> = (0..num_players).map(|_| 0).collect();

  for value in 1..=last_marble {
    let player = (value - 1) % num_players;

    if value % 23 == 0 {
      scores[player] += value;
      circle.move_left(7);
      scores[player] += circle.current_value();
      circle.remove_current();
    } else {
      circle.move_right(1);
      circle.insert_after_current(value);
    }
  }

  scores.into_iter()
    .max()
    .unwrap()
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);

  let mut input = String::new();
  reader.read_to_string(&mut input).unwrap();

  let words: Vec<&str> = input.split_whitespace().collect();

  let num_players: usize = words[0].parse().unwrap();
  let last_marble: usize = words[6].parse().unwrap();

  println!("High score: {}", high_score(num_players, last_marble));
  println!("High score (x100): {}", high_score(num_players, last_marble * 100));
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn marble_circle_operations() {
    let mut circle = MarbleCircle::new();
    assert_eq!(circle.to_vec(), vec![0]);

    circle.insert_after_current(1);
    assert_eq!(circle.to_vec(), vec![1, 0]);

    circle.insert_after_current(2);
    assert_eq!(circle.to_vec(), vec![2, 0, 1]);

    circle.move_right(2);
    assert_eq!(circle.to_vec(), vec![1, 2, 0]);

    circle.move_left(1);
    assert_eq!(circle.to_vec(), vec![0, 1, 2]);

    circle.insert_after_current(3);
    assert_eq!(circle.to_vec(), vec![3, 1, 2, 0]);

    circle.remove_current();
    assert_eq!(circle.to_vec(), vec![1, 2, 0]);

    circle.remove_current();
    assert_eq!(circle.to_vec(), vec![2, 0]);

    circle.remove_current();
    assert_eq!(circle.to_vec(), vec![0]);

    circle.remove_current();
    assert_eq!(circle.to_vec(), vec![0]);
  }

  #[test]
  fn test_high_score() {
    assert_eq!(high_score(9, 25), 32);
    assert_eq!(high_score(10, 1618), 8317);
    assert_eq!(high_score(13, 7999), 146373);
    assert_eq!(high_score(17, 1104), 2764);
    assert_eq!(high_score(21, 6111), 54718);
    assert_eq!(high_score(30, 5807), 37305);
  }
}

