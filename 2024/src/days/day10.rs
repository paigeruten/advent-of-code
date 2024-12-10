use std::{collections::HashSet, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let height_map = HeightMap::parse(input)?;

    let solution = height_map
        .trailheads()
        .into_iter()
        .map(|trailhead| match part {
            Part::One => height_map.trail_score(trailhead),
            Part::Two => height_map.trail_rating(trailhead),
        })
        .sum();

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct HeightMap {
    width: i64,
    height: i64,
    grid: Vec<Vec<i64>>,
}

impl HeightMap {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let grid: Vec<Vec<i64>> = input
            .lines()
            .map(|line| {
                line.unwrap()
                    .chars()
                    .filter_map(|ch| ch.to_digit(10).map(|d| d as i64))
                    .collect()
            })
            .collect();

        Ok(Self {
            width: grid[0].len() as i64,
            height: grid.len() as i64,
            grid,
        })
    }

    pub fn get(&self, pos: Position) -> Option<i64> {
        self.grid
            .get(pos.y as usize)
            .and_then(|row| row.get(pos.x as usize))
            .copied()
    }

    pub fn trailheads(&self) -> Vec<Position> {
        let mut result = Vec::new();
        for y in 0..self.height {
            for x in 0..self.width {
                if self.grid[y as usize][x as usize] == 0 {
                    result.push(Position { x, y });
                }
            }
        }
        result
    }

    pub fn trail_score(&self, pos: Position) -> i64 {
        self.walk_trails(pos).iter().collect::<HashSet<_>>().len() as i64
    }

    pub fn trail_rating(&self, pos: Position) -> i64 {
        self.walk_trails(pos).len() as i64
    }

    fn walk_trails(&self, pos: Position) -> Vec<Position> {
        let mut ends_found = Vec::new();
        self.walk_trails_aux(pos, &mut ends_found);
        ends_found
    }

    fn walk_trails_aux(&self, pos: Position, ends_found: &mut Vec<Position>) {
        let height = self.get(pos).unwrap();
        if height == 9 {
            ends_found.push(pos);
            return;
        }

        for (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
            let next_pos = Position {
                x: pos.x + dx,
                y: pos.y + dy,
            };
            if self.get(next_pos) == Some(height + 1) {
                self.walk_trails_aux(next_pos, ends_found);
            }
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Position {
    x: i64,
    y: i64,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        89010123\n\
        78121874\n\
        87430965\n\
        96549874\n\
        45678903\n\
        32019012\n\
        01329801\n\
        10456732\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(36), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day10").unwrap();
        assert_eq!(Solution::Num(719), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(81), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day10").unwrap();
        assert_eq!(Solution::Num(1530), solve(Part::Two, input).unwrap());
    }
}
