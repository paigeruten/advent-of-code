use std::{fmt, thread, time};
use std::fmt::Display;
use std::io::BufReader;
use std::io::prelude::*;
use std::fs::File;
use std::str::FromStr;

#[derive(Debug, PartialEq, Clone, Copy)]
enum Orientation {
  Horizontal,
  Vertical,
}

#[derive(Debug, PartialEq, Clone, Copy)]
enum Direction {
  Up,
  Down,
  Left,
  Right,
}

impl Direction {
  pub fn orientation(self) -> Orientation {
    use self::Direction::*;
    use self::Orientation::*;

    match self {
      Up   | Down  => Vertical,
      Left | Right => Horizontal,
    }
  }

  pub fn clockwise_turn(self) -> Direction {
    use self::Direction::*;

    match self {
      Up    => Right,
      Right => Down,
      Down  => Left,
      Left  => Up,
    }
  }

  pub fn counter_clockwise_turn(self) -> Direction {
    use self::Direction::*;

    match self {
      Up    => Left,
      Left  => Down,
      Down  => Right,
      Right => Up,
    }
  }

  pub fn curve_up(self) -> Direction {
    use self::Orientation::*;

    match self.orientation() {
      Vertical   => self.clockwise_turn(),
      Horizontal => self.counter_clockwise_turn(),
    }
  }

  pub fn curve_down(self) -> Direction {
    use self::Orientation::*;

    match self.orientation() {
      Vertical   => self.counter_clockwise_turn(),
      Horizontal => self.clockwise_turn(),
    }
  }

  pub fn turn(self, turn: Turning) -> Direction {
    use self::Turning::*;

    match turn {
      Straight         => self,
      Clockwise        => self.clockwise_turn(),
      CounterClockwise => self.counter_clockwise_turn(),
    }
  }
}

impl Display for Direction {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    use self::Direction::*;

    match self {
      Up    => write!(f, "^"),
      Down  => write!(f, "v"),
      Left  => write!(f, "<"),
      Right => write!(f, ">"),
    }
  }
}

#[derive(Debug, PartialEq, Clone, Copy)]
enum Turning {
  CounterClockwise,
  Straight,
  Clockwise,
}

impl Turning {
  pub fn new() -> Turning {
    Turning::CounterClockwise
  }

  pub fn next(self) -> Turning {
    use self::Turning::*;

    match self {
      CounterClockwise => Straight,
      Straight         => Clockwise,
      Clockwise        => CounterClockwise,
    }
  }
}

#[derive(Debug, PartialEq, Clone, Copy)]
enum Track {
  Horizontal,
  Vertical,
  CurveUp,
  CurveDown,
  Intersection,
}

impl Track {
  pub fn from_char(c: char) -> Option<Track> {
    use self::Track::*;

    Some(match c {
      '-' | '<' | '>' => Horizontal,
      '|' | '^' | 'v' => Vertical,
      '/'  => CurveUp,
      '\\' => CurveDown,
      '+'  => Intersection,
       _   => return None
    })
  }
}

impl Display for Track {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    use self::Track::*;

    match self {
      Horizontal   => write!(f, "-"),
      Vertical     => write!(f, "|"),
      CurveUp      => write!(f, "/"),
      CurveDown    => write!(f, "\\"),
      Intersection => write!(f, "+"),
    }
  }
}

#[derive(Debug, PartialEq)]
struct Cart {
  id: usize,
  x: usize,
  y: usize,
  heading: Direction,
  next_turn: Turning,
  crashed: bool,
}

impl Cart {
  pub fn new(id: usize, x: usize, y: usize, heading: Direction) -> Cart {
    Cart {
      id,
      x,
      y,
      heading,
      next_turn: Turning::new(),
      crashed: false
    }
  }

  pub fn position(&self) -> (usize, usize) {
    (self.x, self.y)
  }
}

impl Display for Cart {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    if self.crashed {
      write!(f, "\x1b[1;31mX\x1b[m")
    } else {
      write!(f, "\x1b[1;{}m{}\x1b[m", 41 + ((self.id - 1) % 7), self.heading)
    }
  }
}

#[derive(Debug, PartialEq)]
struct World {
  tracks: Vec<Vec<Option<Track>>>,
  carts: Vec<Cart>,
}

impl World {
  pub fn step(&mut self) -> bool {
    let mut crash = false;

    for index in 0..self.carts.len() {
      {
        let mut cart = &mut self.carts[index];

        if cart.crashed {
          continue;
        }

        match cart.heading {
          Direction::Up    => { cart.y -= 1; },
          Direction::Down  => { cart.y += 1; },
          Direction::Left  => { cart.x -= 1; },
          Direction::Right => { cart.x += 1; },
        }

        match self.tracks[cart.y][cart.x] {
          Some(Track::CurveUp) => {
            cart.heading = cart.heading.curve_up();
          },
          Some(Track::CurveDown) => {
            cart.heading = cart.heading.curve_down();
          },
          Some(Track::Intersection) => {
            cart.heading = cart.heading.turn(cart.next_turn);
            cart.next_turn = cart.next_turn.next();
          },
          _ => ()
        }
      }

      for index2 in 0..self.carts.len() {
        if index != index2 && !self.carts[index2].crashed && self.carts[index].position() == self.carts[index2].position() {
          crash = true;
          self.carts[index].crashed = true;
          self.carts[index2].crashed = true;
        }
      }
    }

    self.carts.sort_unstable_by_key(|cart| (cart.y, cart.x));

    crash
  }
}

impl Display for World {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    for (y, row) in self.tracks.iter().enumerate() {
      for (x, track) in row.iter().enumerate() {
        if let Some(cart) = self.carts.iter().find(|cart| cart.x == x && cart.y == y) {
          write!(f, "{}", cart)?;
        } else if let Some(track) = track {
          write!(f, "{}", track)?;
        } else {
          write!(f, " ")?;
        }
      }
      write!(f, "\n")?;
    }

    Ok(())
  }
}

impl FromStr for World {
  type Err = ();

  fn from_str(input: &str) -> Result<World, ()> {
    let mut carts = Vec::new();
    let mut cart_id = 0;

    let tracks = input
      .lines()
      .enumerate()
      .map(|(y, line)| {
        line
          .chars()
          .enumerate()
          .map(|(x, c)| {
            cart_id += 1;

            match c {
              '^' => carts.push(Cart::new(cart_id, x, y, Direction::Up)),
              'v' => carts.push(Cart::new(cart_id, x, y, Direction::Down)),
              '<' => carts.push(Cart::new(cart_id, x, y, Direction::Left)),
              '>' => carts.push(Cart::new(cart_id, x, y, Direction::Right)),
               _  => cart_id -= 1,
            };

            Track::from_char(c)
          })
          .collect()
      }).collect();

    Ok(World { tracks, carts })
  }
}

#[allow(unused_variables)]
pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);

  let mut input = String::new();
  reader.read_to_string(&mut input).unwrap();

  let mut world: World = input.parse().unwrap();
  let mut first_crash = true;

  let delay = time::Duration::from_millis(50);
  let mut skipping = false;

  loop {
    if !skipping {
      print!("\x1b[2J{}", world);
      thread::sleep(delay);
    }

    if world.step() {
      if first_crash {
        print!("\x1b[2J{}", world);
        if let Some(Cart { x, y, .. }) = world.carts.iter().find(|cart| cart.crashed) {
          println!("First crash at: ({}, {})", x, y);
        }
        first_crash = false;

        print!("Press enter to continue (type 'skip' to not animate the rest): ");
        std::io::stdout().flush().unwrap();
        let mut input_line = String::new();
        std::io::stdin().read_line(&mut input_line).unwrap();

        if input_line.trim() == "skip" {
          skipping = true;
        }
      }

      let not_crashed: Vec<&Cart> = world.carts.iter().filter(|cart| !cart.crashed).collect();
      if not_crashed.len() == 1 {
        print!("\x1b[2J{}", world);
        let Cart { x, y, .. } = not_crashed[0];
        println!("Last remaining cart at: ({}, {})", x, y);
        break;
      }
    }
  }
}

#[cfg(test)]
mod tests {
  use super::*;
  use super::Direction::*;
  use super::Turning::*;

  #[test]
  fn parse_world() {
    let input = String::from(r"
/->-\
|   |  /----\
| /-+--+-\  |
| | |  | v  |
\-+-/  \-+--/
  \------/
");

    let world: World = input.trim().parse().unwrap();

    assert_eq!(
      world.carts,
      vec![
        Cart { id: 1, x: 2, y: 0, heading: Right, next_turn: CounterClockwise, crashed: false },
        Cart { id: 2, x: 9, y: 3, heading: Down, next_turn: CounterClockwise, crashed: false },
      ]
    );
  }

  #[test]
  fn simple_collision() {
    let mut world: World = "->---<-".parse().unwrap();

    assert_eq!(
      world.carts,
      vec![
        Cart { id: 1, x: 1, y: 0, heading: Right, next_turn: CounterClockwise, crashed: false },
        Cart { id: 2, x: 5, y: 0, heading: Left, next_turn: CounterClockwise, crashed: false },
      ]
    );

    assert_eq!(world.step(), false);

    assert_eq!(
      world.carts,
      vec![
        Cart { id: 1, x: 2, y: 0, heading: Right, next_turn: CounterClockwise, crashed: false },
        Cart { id: 2, x: 4, y: 0, heading: Left, next_turn: CounterClockwise, crashed: false },
      ]
    );

    assert_eq!(world.step(), true);

    assert_eq!(
      world.carts,
      vec![
        Cart { id: 1, x: 3, y: 0, heading: Right, next_turn: CounterClockwise, crashed: true },
        Cart { id: 2, x: 3, y: 0, heading: Left, next_turn: CounterClockwise, crashed: true },
      ]
    );

    assert_eq!(world.step(), false);
  }
}

