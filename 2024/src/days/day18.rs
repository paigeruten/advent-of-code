use std::{
    collections::{HashMap, HashSet},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let mut memory_space = MemorySpace::parse(input);

    Ok(match part {
        Part::One => {
            if memory_space.bytes.len() > 1024 {
                memory_space.corrupt(1024);
            } else {
                memory_space.corrupt(12);
            }
            Solution::Num(memory_space.shortest_path().unwrap().len() as i64)
        }
        Part::Two => {
            let first_blocker = memory_space.find_first_blocker().unwrap();
            Solution::Str(format!("{},{}", first_blocker.x, first_blocker.y))
        }
    })
}

#[derive(Debug)]
struct MemorySpace {
    width: i64,
    height: i64,
    bytes: Vec<Vec2>,
    corrupted: HashSet<Vec2>,
}

impl MemorySpace {
    pub fn parse(input: impl BufRead) -> Self {
        let bytes: Vec<Vec2> = input
            .lines()
            .filter_map(|line| {
                line.unwrap().split_once(',').map(|(x, y)| Vec2 {
                    x: x.parse().unwrap(),
                    y: y.parse().unwrap(),
                })
            })
            .collect();

        Self {
            width: bytes.iter().map(|Vec2 { x, .. }| x).max().unwrap() + 1,
            height: bytes.iter().map(|Vec2 { y, .. }| y).max().unwrap() + 1,
            bytes,
            corrupted: HashSet::new(),
        }
    }

    pub fn corrupt(&mut self, count: usize) {
        self.corrupted = self.bytes.iter().take(count).copied().collect();
    }

    pub fn find_first_blocker(&mut self) -> Option<Vec2> {
        let mut shortest_path: Option<Vec<Vec2>> = None;

        self.bytes.clone().into_iter().find(|&byte_pos| {
            self.corrupted.insert(byte_pos);

            // Only recalculate the shortest path when a byte lands on the
            // current shortest path.
            if shortest_path
                .as_ref()
                .is_none_or(|path| path.contains(&byte_pos))
            {
                shortest_path = self.shortest_path();
            }

            shortest_path.is_none()
        })
    }

    pub fn shortest_path(&self) -> Option<Vec<Vec2>> {
        let start = Vec2 { x: 0, y: 0 };

        let mut frontier = vec![start];
        let mut visited: HashSet<Vec2> = frontier.iter().copied().collect();
        let mut prev: HashMap<Vec2, Vec2> = HashMap::new();

        while !frontier.is_empty() {
            let mut next_frontier = Vec::new();
            for &pos in frontier.iter() {
                // If at the goal square, reconstruct the shortest path by
                // following `prev` backward to the start.
                if pos.x == self.width - 1 && pos.y == self.height - 1 {
                    let mut path = Vec::new();
                    let mut cur_pos = pos;
                    while (cur_pos.x, cur_pos.y) != (0, 0) {
                        let prev_pos = *prev.get(&cur_pos).unwrap();
                        path.push(prev_pos);
                        cur_pos = prev_pos;
                    }
                    return Some(path);
                }

                for (dx, dy) in [(0, -1), (1, 0), (0, 1), (-1, 0)] {
                    let neighbour = Vec2 {
                        x: pos.x + dx,
                        y: pos.y + dy,
                    };
                    if !self.is_space(&neighbour) || visited.contains(&neighbour) {
                        continue;
                    }

                    next_frontier.push(neighbour);
                    prev.insert(neighbour, pos);
                    visited.insert(neighbour);
                }
            }
            frontier = next_frontier;
        }

        None
    }

    fn is_space(&self, pos: &Vec2) -> bool {
        (0..self.width).contains(&pos.x)
            && (0..self.height).contains(&pos.y)
            && !self.corrupted.contains(pos)
    }
}

#[derive(Debug, Clone, Copy, PartialOrd, Ord, PartialEq, Eq, Hash)]
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
        5,4\n\
        4,2\n\
        4,5\n\
        3,0\n\
        2,1\n\
        6,3\n\
        2,4\n\
        1,5\n\
        0,6\n\
        3,3\n\
        2,6\n\
        5,1\n\
        1,2\n\
        5,5\n\
        2,5\n\
        6,5\n\
        1,4\n\
        0,4\n\
        6,4\n\
        1,1\n\
        6,1\n\
        1,0\n\
        0,5\n\
        1,6\n\
        2,0\n\
    ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(22), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day18").unwrap();
        assert_eq!(Solution::Num(286), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(
            Solution::Str("6,1".into()),
            solve(Part::Two, input).unwrap()
        );
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day18").unwrap();
        assert_eq!(
            Solution::Str("20,64".into()),
            solve(Part::Two, input).unwrap()
        );
    }
}
