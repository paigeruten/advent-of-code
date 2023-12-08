use std::fmt;
use std::fmt::Display;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;

#[derive(Debug, PartialEq, Copy, Clone)]
struct Point(usize, usize);

impl Point {
  pub fn x(&self) -> usize {
    self.0
  }

  pub fn y(&self) -> usize {
    self.1
  }

  pub fn power_level(&self, serial_number: usize) -> i32 {
    let rack_id = self.x() + 10;
    let power_level = (rack_id * self.y() + serial_number) * rack_id;
    let hundreds_digit = power_level / 100 % 10;

    (hundreds_digit as i32) - 5
  }
}

impl Display for Point {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    write!(f, "{},{}", self.x(), self.y())
  }
}

struct Grid {
  grid: Vec<i32>,
  width: usize,
  height: usize,
  serial_number: usize,
}

impl Grid {
  pub fn new(width: usize, height: usize, serial_number: usize) -> Grid {
    Grid {
      grid: vec![0; width * height],
      width,
      height,
      serial_number,
    }
  }

  pub fn get_point(&self, point: Point) -> i32 {
    let x = point.x() - 1;
    let y = point.y() - 1;
    self.grid[y * self.width + x]
  }

  pub fn set_point(&mut self, point: Point, power_level: i32) {
    let x = point.x() - 1;
    let y = point.y() - 1;
    self.grid[y * self.width + x] = power_level;
  }

  pub fn calculate_all(&mut self) {
    for y in 1..=self.height {
      for x in 1..=self.width {
        let point = Point(x, y);
        self.set_point(point, point.power_level(self.serial_number));
      }
    }
  }

  pub fn find_maximum_window(&self) -> (Point, usize) {
    let mut max_window = Point(1, 1);
    let mut max_total = self.window_total(max_window, 1);
    let mut max_size = 1;

    for size in 1..=self.width {
      let (window, total) = self.find_maximum_window_of_size(size);
      if total > max_total {
        max_total = total;
        max_window = window;
        max_size = size;
      }
    }

    (max_window, max_size)
  }

  pub fn find_maximum_window_of_size(&self, size: usize) -> (Point, i32) {
    let mut max_window = Point(1, 1);
    let mut max_total = self.window_total(max_window, size);

    for y in 1..=(self.height - size + 1) {
      for x in 1..=(self.width - size + 1) {
        let total = self.window_total(Point(x, y), size);
        if total > max_total {
          max_total = total;
          max_window = Point(x, y);
        }
      }
    }

    (max_window, max_total)
  }

  fn window_total(&self, upper_left: Point, size: usize) -> i32 {
    let Point(x, y) = upper_left;

    let mut total = 0;
    for dy in 0..size {
      for dx in 0..size {
        total += self.get_point(Point(x + dx, y + dy));
      }
    }

    total
  }
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);

  let mut input = String::new();
  reader.read_to_string(&mut input).unwrap();

  let serial_number: usize = input.trim().parse().unwrap();

  let mut grid = Grid::new(300, 300, serial_number);
  grid.calculate_all();

  let (max_3x3_window, _) = grid.find_maximum_window_of_size(3);
  let (max_window, max_window_size) = grid.find_maximum_window();

  println!("Max 3x3 window: {}", max_3x3_window);
  println!("Max window: {},{}", max_window, max_window_size);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_power_level() {
    assert_eq!(4, Point(3, 5).power_level(8));
    assert_eq!(-5, Point(122, 79).power_level(57));
    assert_eq!(0, Point(217, 196).power_level(39));
    assert_eq!(4, Point(101, 153).power_level(71));
  }
}

