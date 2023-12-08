use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::num::ParseIntError;
use std::str::FromStr;

#[derive(Debug, PartialEq, Eq, Hash, Clone, Copy)]
struct Point(i32, i32);

impl Point {
  pub fn closest(self, points: &[Point]) -> Option<Point> {
    let mut min_distance = None;
    let mut closest_point = None;
    let mut tied = false;

    for &point in points {
      let distance = self.manhattan_distance(point);
      if min_distance.is_none() || distance < min_distance.unwrap() {
        min_distance = Some(distance);
        closest_point = Some(point);
        tied = false;
      } else if distance == min_distance.unwrap() {
        tied = true;
      }
    }

    if tied { None } else { closest_point }
  }

  pub fn total_distance(self, points: &[Point]) -> i32 {
    points.iter()
      .map(|&point| self.manhattan_distance(point))
      .sum()
  }

  pub fn manhattan_distance(self, other: Point) -> i32 {
    let Point(x1, y1) = self;
    let Point(x2, y2) = other;

    (x2 - x1).abs() + (y2 - y1).abs()
  }
}

impl FromStr for Point {
  type Err = ParseIntError;

  fn from_str(string: &str) -> Result<Self, Self::Err> {
    let coords: Vec<i32> = string
      .split(", ")
      .map(|n| n.parse())
      .collect::<Result<_, _>>()?;

    Ok(Point(coords[0], coords[1]))
  }
}

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let points: Vec<Point> = reader
    .lines()
    .flatten()
    .map(|line| line.parse())
    .flatten()
    .collect();

  let &left   = points.iter().map(|Point(x, _)| x).min().unwrap();
  let &right  = points.iter().map(|Point(x, _)| x).max().unwrap();
  let &top    = points.iter().map(|Point(_, y)| y).min().unwrap();
  let &bottom = points.iter().map(|Point(_, y)| y).max().unwrap();

  let mut area_by_point = HashMap::new();
  let mut safe_area = 0;

  for y in top..bottom {
    for x in left..right {
      if let Some(point) = Point(x, y).closest(&points) {
        let area = area_by_point.entry(point).or_insert(0);
        if x == left || x == right || y == top || y == bottom {
          *area = -1;
        } else if *area != -1 {
          *area += 1;
        }
      }

      if Point(x, y).total_distance(&points) < 10_000 {
        safe_area += 1;
      }
    }
  }

  let max_area = area_by_point.iter()
    .map(|(_, area)| area)
    .max()
    .unwrap();

  println!("Max area: {}", max_area);
  println!("Safe area: {}", safe_area);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_point_parse() {
    assert_eq!(
      "192, 220".parse(),
      Ok(Point(192, 220))
    );
  }

  #[test]
  fn test_point_closest() {
    let coords = vec![
      Point(1, 1),
      Point(1, 6),
      Point(8, 3),
      Point(3, 4),
      Point(5, 5),
      Point(8, 9),
    ];

    assert_eq!(
      Point(4, 7).closest(&coords),
      Some(Point(5, 5))
    );
    assert_eq!(
      Point(1, 1).closest(&coords),
      Some(Point(1, 1))
    );
    assert_eq!(
      Point(5, 1).closest(&coords),
      None
    );
  }

  #[test]
  fn test_point_total_distance() {
    let coords = vec![
      Point(1, 1),
      Point(1, 6),
      Point(8, 3),
      Point(3, 4),
      Point(5, 5),
      Point(8, 9),
    ];

    assert_eq!(
      Point(4, 3).total_distance(&coords),
      30
    );
  }

  #[test]
  fn test_point_manhattan_distance() {
    assert_eq!(
      Point(4, 7).manhattan_distance(Point(2, 3)),
      6
    );
  }
}
