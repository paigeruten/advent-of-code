use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::fmt;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::thread;
use std::time::Duration;

#[derive(Debug, PartialEq, Clone, Copy)]
enum Material {
  Sand,
  Clay,
  FlowingWater,
  StillWater,
  Spring,
}
use self::Material::*;

impl Material {
  pub fn is_water(self) -> bool {
    match self {
      FlowingWater | StillWater => true,
      _ => false,
    }
  }
}

#[derive(Debug)]
struct World {
  map: HashMap<(i32, i32), Material>,
  min_x: i32,
  max_x: i32,
  min_clay_y: i32,
  max_clay_y: i32,
  animate_ms: i32,
}

impl World {
  pub fn new() -> World {
    World { map: HashMap::new(), min_x: 0, max_x: 0, min_clay_y: 0, max_clay_y: 0, animate_ms: 0 }
  }

  pub fn set_animate_ms(&mut self, ms: i32) {
    self.animate_ms = ms;
  }

  pub fn get_tile(&self, x: i32, y: i32) -> Material {
    *self.map.get(&(x, y)).unwrap_or(&Sand)
  }

  pub fn set_tile(&mut self, x: i32, y: i32, material: Material) {
    if self.map.is_empty() {
      self.min_x = x;
      self.max_x = x;
      self.min_clay_y = y;
      self.max_clay_y = y;
    }

    if x < self.min_x { self.min_x = x; }
    if x > self.max_x { self.max_x = x; }
    if y < self.min_clay_y && material == Clay { self.min_clay_y = y; }
    if y > self.max_clay_y && material == Clay { self.max_clay_y = y; }

    self.map.insert((x, y), material);
  }

  pub fn num_water_tiles(&self) -> usize {
    self.map.iter()
      .filter(|(_, material)| material.is_water())
      .filter(|(&(_, y), _)| y >= self.min_clay_y && y <= self.max_clay_y)
      .count()
  }

  pub fn num_still_water_tiles(&self) -> usize {
    self.map.iter()
      .filter(|(_, &material)| material == StillWater)
      .filter(|(&(_, y), _)| y >= self.min_clay_y && y <= self.max_clay_y)
      .count()
  }

  pub fn start_spring(&mut self, x: i32, y: i32) {
    self.set_tile(x, y, Spring);
    self.animation_frame();

    self.flow_down(x, y + 1);
  }

  fn flow_down(&mut self, x: i32, y: i32) -> Material {
    if y > self.max_clay_y {
      self.set_tile(x, y, FlowingWater);
      self.animation_frame();
      return FlowingWater;
    }

    self.set_tile(x, y, FlowingWater);
    self.animation_frame();

    if self.get_tile(x, y + 1) == FlowingWater {
      return FlowingWater;
    }

    if self.get_tile(x, y + 1) != Sand || self.flow_down(x, y + 1) == StillWater {
      let left_flowing = self.flow_left(x - 1, y);
      let right_flowing = self.flow_right(x + 1, y);
      if !left_flowing && !right_flowing {
        let mut left_x = x;
        while self.get_tile(left_x, y).is_water() {
          self.set_tile(left_x, y, StillWater);
          left_x -= 1;
        }

        let mut right_x = x + 1;
        while self.get_tile(right_x, y).is_water() {
          self.set_tile(right_x, y, StillWater);
          right_x += 1;
        }

        self.animation_frame();

        return StillWater;
      }
    }
    FlowingWater
  }

  fn flow_left(&mut self, x: i32, y: i32) -> bool {
    if self.get_tile(x, y) != Sand { return false; }

    self.set_tile(x, y, FlowingWater);
    self.animation_frame();
    if self.get_tile(x, y + 1) == Sand {
      if self.flow_down(x, y + 1) == FlowingWater {
        return true;
      }
    }
    return self.flow_left(x - 1, y);
  }

  fn flow_right(&mut self, x: i32, y: i32) -> bool {
    if self.get_tile(x, y) != Sand { return false; }

    self.set_tile(x, y, FlowingWater);
    self.animation_frame();
    if self.get_tile(x, y + 1) == Sand {
      if self.flow_down(x, y + 1) == FlowingWater {
        return true;
      }
    }
    return self.flow_right(x + 1, y);
  }

  fn animation_frame(&self) {
    if self.animate_ms == 0 { return; }

    println!("{}\n", self);
    thread::sleep(Duration::from_millis(self.animate_ms as u64));
  }
}

impl fmt::Display for World {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    for y in 0 ..= self.max_clay_y+1 {
      for x in self.min_x-1 ..= self.max_x+1 {
        match self.map.get(&(x, y)).unwrap_or(&Sand) {
          Sand         => write!(f, "."),
          Clay         => write!(f, "\x1b[33m#\x1b[0m"),
          FlowingWater => write!(f, "\x1b[1;34m|\x1b[0m"),
          StillWater   => write!(f, "\x1b[1;36m~\x1b[0m"),
          Spring       => write!(f, "\x1b[1;35m+\x1b[0m"),
        }?
      }
      write!(f, "\n")?;
    }
    Ok(())
  }
}

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let mut world = World::new();

  for line in reader.lines() {
    lazy_static! {
      static ref ROW_REGEX: Regex =
        Regex::new(r"^y=(\d+), x=(\d+)\.\.(\d+)$").unwrap();
      static ref COL_REGEX: Regex =
        Regex::new(r"^x=(\d+), y=(\d+)\.\.(\d+)$").unwrap();
    }

    let line = line.unwrap();
    if let Some(caps) = ROW_REGEX.captures(&line) {
      let y:  i32 = caps.get(1).unwrap().as_str().parse().unwrap();
      let x1: i32 = caps.get(2).unwrap().as_str().parse().unwrap();
      let x2: i32 = caps.get(3).unwrap().as_str().parse().unwrap();

      for x in x1..=x2 {
        world.set_tile(x, y, Clay);
      }
    } else if let Some(caps) = COL_REGEX.captures(&line) {
      let x:  i32 = caps.get(1).unwrap().as_str().parse().unwrap();
      let y1: i32 = caps.get(2).unwrap().as_str().parse().unwrap();
      let y2: i32 = caps.get(3).unwrap().as_str().parse().unwrap();

      for y in y1..=y2 {
        world.set_tile(x, y, Clay);
      }
    }
  }

  //world.set_animate_ms(150);

  world.start_spring(500, 0);
  println!("{}\n", world);

  println!("Number of water tiles: {}", world.num_water_tiles());
  println!("Water left after draining: {}", world.num_still_water_tiles());
}

