use lazy_static::lazy_static;
use regex::Regex;
use std::fmt;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;

#[derive(Debug, PartialEq)]
struct Particle {
  x: i32,
  y: i32,
  vx: i32,
  vy: i32,
}

impl Particle {
  pub fn update(&mut self) {
    self.x += self.vx;
    self.y += self.vy;
  }

  pub fn rollback(&mut self) {
    self.x -= self.vx;
    self.y -= self.vy;
  }
}

impl FromStr for Particle {
  type Err = ();

  fn from_str(string: &str) -> Result<Particle, Self::Err> {
    lazy_static! {
      static ref PARTICLE_REGEX: Regex =
        Regex::new(r"^position=< *(-?\d+), *(-?\d+)> velocity=< *(-?\d+), *(-?\d+)>$").unwrap();
    }

    if let Some(caps) = PARTICLE_REGEX.captures(string) {
      let x:  i32 = caps.get(1).unwrap().as_str().parse().unwrap();
      let y:  i32 = caps.get(2).unwrap().as_str().parse().unwrap();
      let vx: i32 = caps.get(3).unwrap().as_str().parse().unwrap();
      let vy: i32 = caps.get(4).unwrap().as_str().parse().unwrap();

      Ok(Particle { x, y, vx, vy })
    } else {
      Err(())
    }
  }
}

#[derive(Debug, PartialEq)]
struct Simulation {
  particles: Vec<Particle>,
}

impl Simulation {
  pub fn update_while_converging(&mut self) -> i32 {
    let mut last_area = self.bounding_box_area();
    let mut area = last_area;
    let mut time = 0;

    while area <= last_area {
      self.update();
      time += 1;
      last_area = area;
      area = self.bounding_box_area();
    }

    self.rollback();

    time - 1
  }

  fn update(&mut self) {
    for particle in self.particles.iter_mut() {
      particle.update();
    }
  }

  fn rollback(&mut self) {
    for particle in self.particles.iter_mut() {
      particle.rollback();
    }
  }

  // Returns in CSS order: (top, right, bottom, left)
  fn bounding_box(&self) -> (i32, i32, i32, i32) {
    let mut min_y = self.particles[0].y;
    let mut max_x = self.particles[0].x;
    let mut max_y = self.particles[0].y;
    let mut min_x = self.particles[0].x;

    for &Particle { x, y, .. } in self.particles.iter() {
      if x < min_x { min_x = x; }
      if x > max_x { max_x = x; }
      if y < min_y { min_y = y; }
      if y > max_y { max_y = y; }
    }

    (min_y, max_x, max_y, min_x)
  }

  fn bounding_box_area(&self) -> i64 {
    let (top, right, bottom, left) = self.bounding_box();
    (right - left) as i64 * (bottom - top) as i64
  }

  fn has_particle(&self, px: i32, py: i32) -> bool {
    self.particles.iter()
      .find(|Particle { x, y, .. }| *x == px && *y == py)
      .is_some()
  }
}

impl fmt::Display for Simulation {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    let (top, right, bottom, left) = self.bounding_box();

    for y in top..=bottom {
      for x in left..=right {
        if self.has_particle(x, y) {
          write!(f, "#")?;
        } else {
          write!(f, ".")?;
        }
      }
      write!(f, "\n")?;
    }

    Ok(())
  }
}

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let particles = reader
    .lines()
    .flatten()
    .map(|line| line.parse::<Particle>())
    .collect::<Result<Vec<_>, _>>()
    .unwrap();

  let mut simulation = Simulation { particles };

  let time = simulation.update_while_converging();

  print!("Time: {} seconds\n\n{}", time, simulation);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn particle_update_and_rollback() {
    let mut particle = Particle { x: -2, y: 3, vx: 1, vy: -5 };

    particle.update();
    assert_eq!(particle.x, -1);
    assert_eq!(particle.y, -2);

    particle.rollback();
    assert_eq!(particle.x, -2);
    assert_eq!(particle.y, 3);
  }

  #[test]
  fn bounding_box() {
    let simulation = Simulation {
      particles: vec![
        Particle { x: 9, y: 1, vx: 0, vy: 0 },
        Particle { x: 7, y: 0, vx: 0, vy: 0 },
        Particle { x: 3, y: -2, vx: 0, vy: 0 },
      ]
    };

    assert_eq!(
      simulation.bounding_box(),
      (-2, 9, 1, 3)
    );

    assert_eq!(18, simulation.bounding_box_area());
  }

  #[test]
  fn update_while_converging() {
    let mut simulation = Simulation {
      particles: vec![
        Particle { x:  9, y:  1, vx:  0, vy:  2 },
        Particle { x:  7, y:  0, vx: -1, vy:  0 },
        Particle { x:  3, y: -2, vx: -1, vy:  1 },
        Particle { x:  6, y: 10, vx: -2, vy: -1 },
        Particle { x:  2, y: -4, vx:  2, vy:  2 },
        Particle { x: -6, y: 10, vx:  2, vy: -2 },
        Particle { x:  1, y:  8, vx:  1, vy: -1 },
        Particle { x:  1, y:  7, vx:  1, vy:  0 },
        Particle { x: -3, y: 11, vx:  1, vy: -2 },
        Particle { x:  7, y:  6, vx: -1, vy: -1 },
        Particle { x: -2, y:  3, vx:  1, vy:  0 },
        Particle { x: -4, y:  3, vx:  2, vy:  0 },
        Particle { x: 10, y: -3, vx: -1, vy:  1 },
        Particle { x:  5, y: 11, vx:  1, vy: -2 },
        Particle { x:  4, y:  7, vx:  0, vy: -1 },
        Particle { x:  8, y: -2, vx:  0, vy:  1 },
        Particle { x: 15, y:  0, vx: -2, vy:  0 },
        Particle { x:  1, y:  6, vx:  1, vy:  0 },
        Particle { x:  8, y:  9, vx:  0, vy: -1 },
        Particle { x:  3, y:  3, vx: -1, vy:  1 },
        Particle { x:  0, y:  5, vx:  0, vy: -1 },
        Particle { x: -2, y:  2, vx:  2, vy:  0 },
        Particle { x:  5, y: -2, vx:  1, vy:  2 },
        Particle { x:  1, y:  4, vx:  2, vy:  1 },
        Particle { x: -2, y:  7, vx:  2, vy: -2 },
        Particle { x:  3, y:  6, vx: -1, vy: -1 },
        Particle { x:  5, y:  0, vx:  1, vy:  0 },
        Particle { x: -6, y:  0, vx:  2, vy:  0 },
        Particle { x:  5, y:  9, vx:  1, vy: -2 },
        Particle { x: 14, y:  7, vx: -2, vy:  0 },
        Particle { x: -3, y:  6, vx:  2, vy: -1 },
      ]
    };

    let time = simulation.update_while_converging();

    assert_eq!(time, 3);

    assert_eq!(
      format!("{}", simulation),
"#...#..###
#...#...#.
#...#...#.
#####...#.
#...#...#.
#...#...#.
#...#...#.
#...#..###
"
    );
  }

  #[test]
  fn parse_particle() {
    let particle: Particle = "position=<-3, 11> velocity=< 1, -2>".parse().unwrap();

    assert_eq!(particle, Particle { x: -3, y: 11, vx: 1, vy: -2 });
  }
}

