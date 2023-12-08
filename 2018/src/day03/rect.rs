use std::num::ParseIntError;
use std::str::FromStr;

#[derive(Debug, PartialEq)]
pub struct Rectangle {
  pub id: u32,
  pub x: u32,
  pub y: u32,
  pub w: u32,
  pub h: u32
}

pub struct Points<'a> {
  rectangle: &'a Rectangle,
  last_point: Option<(u32, u32)>
}

impl<'a> Iterator for Points<'a> {
  type Item = (u32, u32);

  fn next(&mut self) -> Option<(u32, u32)> {
    let (mut next_x, mut next_y) = match self.last_point {
      Some((x, y)) => (x + 1, y),
      None => (self.rectangle.x, self.rectangle.y),
    };

    if next_x > self.rectangle.right() {
      next_x = self.rectangle.x;
      next_y += 1;
    }

    if next_y > self.rectangle.bottom() {
      self.last_point = None;
    } else {
      self.last_point = Some((next_x, next_y));
    }

    self.last_point
  }
}

impl Rectangle {
  pub fn points(&self) -> Points {
    Points { rectangle: self, last_point: None }
  }

  pub fn top(&self) -> u32 {
    self.y
  }

  pub fn bottom(&self) -> u32 {
    self.y + self.h - 1
  }

  pub fn left(&self) -> u32 {
    self.x
  }

  pub fn right(&self) -> u32 {
    self.x + self.w - 1
  }

  pub fn overlaps(&self, other: &Rectangle) -> bool {
    !(
      other.right() < self.left() ||
      other.bottom() < self.top() ||
      other.left() > self.right() ||
      other.top() > self.bottom()
    )
  }
}

impl AsRef<Rectangle> for Rectangle {
  fn as_ref(&self) -> &Rectangle {
    self
  }
}

impl FromStr for Rectangle {
  type Err = ParseIntError;

  fn from_str(string: &str) -> Result<Self, Self::Err> {
    let nums: Vec<u32> = string
      .split(|c: char| !c.is_numeric())
      .filter(|n| !n.is_empty())
      .map(|n| n.parse())
      .collect::<Result<Vec<u32>, ParseIntError>>()?;

    Ok(Rectangle { id: nums[0], x: nums[1], y: nums[2], w: nums[3], h: nums[4] })
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_rectangle_points() {
    assert_eq!(
      Rectangle { id: 1, x: 3, y: 4, w: 2, h: 3 }.points().collect::<Vec<(u32, u32)>>(),
      vec![(3, 4), (4, 4), (3, 5), (4, 5), (3, 6), (4, 6)]
    );
    assert_eq!(
      Rectangle { id: 1, x: 3, y: 4, w: 1, h: 1 }.points().collect::<Vec<(u32, u32)>>(),
      vec![(3, 4)]
    );
    assert_eq!(
      Rectangle { id: 1, x: 3, y: 4, w: 0, h: 0 }.points().collect::<Vec<(u32, u32)>>(),
      vec![]
    );
  }

  #[test]
  fn test_rectangle_overlaps() {
    assert!(
      Rectangle { id: 1, x: 1, y: 2, w: 2, h: 3 }.overlaps(
        &Rectangle { id: 2, x: 2, y: 4, w: 3, h: 3 }
      )
    );
    assert!(
      Rectangle { id: 1, x: 2, y: 4, w: 3, h: 3 }.overlaps(
        &Rectangle { id: 2, x: 1, y: 2, w: 2, h: 3 }
      )
    );
    assert!(
      Rectangle { id: 1, x: 2, y: 4, w: 3, h: 3 }.overlaps(
        &Rectangle { id: 2, x: 4, y: 2, w: 2, h: 3 }
      )
    );
    assert!(
      Rectangle { id: 1, x: 4, y: 2, w: 2, h: 3 }.overlaps(
        &Rectangle { id: 2, x: 2, y: 4, w: 3, h: 3 }
      )
    );
    assert!(
      Rectangle { id: 1, x: 4, y: 2, w: 2, h: 2 }.overlaps(
        &Rectangle { id: 2, x: 3, y: 1, w: 5, h: 5 }
      )
    );
    assert!(
      ! Rectangle { id: 1, x: 1, y: 2, w: 2, h: 3 }.overlaps(
        &Rectangle { id: 2, x: 3, y: 4, w: 3, h: 3 }
      )
    );
  }

  #[test]
  fn test_rectangle_from_str() {
    assert_eq!(
      "#1 @ 1,3: 4x4".parse(),
      Ok(Rectangle { id: 1, x: 1, y: 3, w: 4, h: 4 })
    );
    assert_eq!(
      "#34 @ 36,23: 41x37".parse(),
      Ok(Rectangle { id: 34, x: 36, y: 23, w: 41, h: 37 })
    );
  }
}
