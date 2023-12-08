use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use self::rect::Rectangle;

mod rect;

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let claims: Vec<Rectangle> = reader
    .lines()
    .flatten()
    .map(|line| line.parse())
    .flatten()
    .collect();

  println!("Total overlapping area: {}", overlapping_area(&claims));
  println!("Nonoverlapping claim id: {}", find_nonoverlapping_claim(&claims).unwrap());
}

fn overlapping_area<T: AsRef<Rectangle>>(claims: &[T]) -> u32 {
  let mut fabric: HashMap<(u32, u32), u32> = HashMap::new();
  for rect in claims.iter() {
    for point in rect.as_ref().points() {
      *fabric.entry(point).or_insert(0) += 1;
    }
  }
  fabric.values().filter(|&&n| n >= 2).count() as u32
}

fn find_nonoverlapping_claim<T: AsRef<Rectangle>>(claims: &[T]) -> Option<u32> {
  'next: for (index, rect) in claims.iter().enumerate() {
    for (other_index, other_rect) in claims.iter().enumerate() {
      if index != other_index && rect.as_ref().overlaps(other_rect.as_ref()) {
        continue 'next;
      }
    }
    return Some(rect.as_ref().id);
  }

  None
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_overlapping_area() {
    assert_eq!(
      4,
      overlapping_area(&[
        Rectangle { id: 1, x: 1, y: 3, w: 4, h: 4 },
        Rectangle { id: 2, x: 3, y: 1, w: 4, h: 4 },
        Rectangle { id: 3, x: 5, y: 5, w: 2, h: 2 },
      ])
    );
  }

  #[test]
  fn test_find_nonoverlapping_claim() {
    assert_eq!(
      Some(3),
      find_nonoverlapping_claim(&[
        Rectangle { id: 1, x: 1, y: 3, w: 4, h: 4 },
        Rectangle { id: 2, x: 3, y: 1, w: 4, h: 4 },
        Rectangle { id: 3, x: 5, y: 5, w: 2, h: 2 },
      ])
    );
  }
}
