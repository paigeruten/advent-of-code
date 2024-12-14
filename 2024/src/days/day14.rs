use std::{
    cmp::Ordering,
    collections::HashSet,
    fmt::{Display, Write},
    io::BufRead,
};

use regex::Regex;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let mut world = World::parse(input)?;

    let solution = match part {
        Part::One => {
            for _ in 0..100 {
                world.step();
            }
            world.safety_factor()
        }
        Part::Two => (1..)
            .find(|_| {
                world.step();
                world.has_christmas_tree()
            })
            .unwrap(),
    };

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct World {
    bounds: Vec2,
    robots: Vec<Robot>,
}

impl World {
    pub fn parse(mut input: impl BufRead) -> color_eyre::Result<Self> {
        let mut input_str = String::new();
        input.read_to_string(&mut input_str)?;

        let re = Regex::new(r"p=(\d+),(\d+) v=(-?\d+),(-?\d+)").unwrap();

        let robots: Vec<_> = re
            .captures_iter(&input_str)
            .map(|c| c.extract())
            .map(|(_, [x, y, vx, vy])| Robot {
                position: Vec2 {
                    x: x.parse().unwrap(),
                    y: y.parse().unwrap(),
                },
                velocity: Vec2 {
                    x: vx.parse().unwrap(),
                    y: vy.parse().unwrap(),
                },
            })
            .collect();

        Ok(Self {
            bounds: Vec2 {
                x: robots.iter().map(|robot| robot.position.x).max().unwrap() + 1,
                y: robots.iter().map(|robot| robot.position.y).max().unwrap() + 1,
            },
            robots,
        })
    }

    pub fn step(&mut self) {
        for robot in self.robots.iter_mut() {
            robot.position.x = (robot.position.x + robot.velocity.x).rem_euclid(self.bounds.x);
            robot.position.y = (robot.position.y + robot.velocity.y).rem_euclid(self.bounds.y);
        }
    }

    pub fn safety_factor(&self) -> i64 {
        let (mut nw, mut ne, mut sw, mut se) = (0, 0, 0, 0);

        let (mid_x, mid_y) = (self.bounds.x / 2, self.bounds.y / 2);

        for robot in self.robots.iter() {
            match (robot.position.x.cmp(&mid_x), robot.position.y.cmp(&mid_y)) {
                (Ordering::Less, Ordering::Less) => nw += 1,
                (Ordering::Greater, Ordering::Less) => ne += 1,
                (Ordering::Less, Ordering::Greater) => sw += 1,
                (Ordering::Greater, Ordering::Greater) => se += 1,
                _ => {}
            }
        }

        nw * ne * sw * se
    }

    pub fn has_christmas_tree(&self) -> bool {
        let robot_set: HashSet<Vec2> = self.robots.iter().map(|robot| robot.position).collect();

        // Just look for the tree trunk
        for y in 72..=74 {
            for x in 54..=56 {
                if !robot_set.contains(&Vec2 { x, y }) {
                    return false;
                }
            }
        }
        true
    }
}

impl Display for World {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let robot_set: HashSet<Vec2> = self.robots.iter().map(|robot| robot.position).collect();

        for y in 0..self.bounds.y {
            for x in 0..self.bounds.x {
                if robot_set.contains(&Vec2 { x, y }) {
                    f.write_char('#')?;
                } else {
                    f.write_char('.')?;
                }
            }
            f.write_char('\n')?;
        }

        Ok(())
    }
}

#[derive(Debug)]
struct Robot {
    position: Vec2,
    velocity: Vec2,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Vec2 {
    x: i64,
    y: i64,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        p=0,4 v=3,-3\n\
        p=6,3 v=-1,-3\n\
        p=10,3 v=-1,2\n\
        p=2,0 v=2,-1\n\
        p=0,0 v=1,3\n\
        p=3,0 v=-2,-2\n\
        p=7,6 v=-1,-3\n\
        p=3,0 v=-1,-2\n\
        p=9,3 v=2,3\n\
        p=7,3 v=-1,2\n\
        p=2,4 v=2,-3\n\
        p=9,5 v=-3,-3\n\
    ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(12), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day14").unwrap();
        assert_eq!(Solution::Num(211692000), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day14").unwrap();
        assert_eq!(Solution::Num(6587), solve(Part::Two, input).unwrap());
    }
}
