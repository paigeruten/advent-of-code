use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::collections::HashSet;
use std::iter::FromIterator;

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let freq_changes: Vec<i32> = reader.lines().map(|line|
    line.unwrap().parse().unwrap()
  ).collect();

  println!(
    "Resulting frequency: {}",
    resulting_frequency(&freq_changes)
  );
  println!(
    "First frequency reached twice: {}",
    first_frequency_reached_twice(&freq_changes)
  );
}

fn resulting_frequency(freq_changes: &[i32]) -> i32 {
  freq_changes.iter().sum()
}

fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  let mut seen: HashSet<i32> = HashSet::from_iter(vec![0]);

  freq_changes.iter()
    .cycle()
    .scan(0, |freq, &change| {
      *freq += change;
      Some(*freq)
    })
    .find(|&freq| !seen.insert(freq))
    .unwrap()
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_resulting_frequency() {
    assert_eq!(3, resulting_frequency(&[1, -2, 3, 1]));
    assert_eq!(3, resulting_frequency(&[1, 1, 1]));
    assert_eq!(0, resulting_frequency(&[1, 1, -2]));
    assert_eq!(-6, resulting_frequency(&[-1, -2, -3]));
  }

  #[test]
  fn test_first_frequency_reached_twice() {
    assert_eq!(2, first_frequency_reached_twice(&[1, -2, 3, 1]));
    assert_eq!(0, first_frequency_reached_twice(&[1, -1]));
    assert_eq!(10, first_frequency_reached_twice(&[3, 3, 4, -2, -4]));
    assert_eq!(5, first_frequency_reached_twice(&[-6, 3, 8, 5, -6]));
    assert_eq!(14, first_frequency_reached_twice(&[7, 7, -2, -7, -4]));
  }
}
