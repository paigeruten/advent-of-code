use std::{collections::HashMap, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let num_blinks = match part {
        Part::One => 25,
        Part::Two => 75,
    };

    let num_stones =
        std::iter::successors(Some(Stones::parse(input)?), |stones| Some(stones.blink()))
            .nth(num_blinks)
            .unwrap()
            .count();

    Ok(Solution::Num(num_stones))
}

struct Stones(HashMap<i64, i64>);

impl Stones {
    pub fn new() -> Self {
        Self(HashMap::new())
    }

    pub fn with_capacity(size: usize) -> Self {
        Self(HashMap::with_capacity(size))
    }

    pub fn parse(mut input: impl BufRead) -> color_eyre::Result<Self> {
        let mut line = String::new();
        input.read_line(&mut line)?;

        let mut stones = Self::new();
        for stone in line.split_whitespace() {
            stones.add(stone.parse()?, 1);
        }
        Ok(stones)
    }

    pub fn add(&mut self, stone: i64, count: i64) {
        *self.0.entry(stone).or_insert(0) += count;
    }

    pub fn blink(&self) -> Stones {
        let mut next_stones = Stones::with_capacity(self.0.len());
        for (&stone, &count) in self.0.iter() {
            if stone == 0 {
                next_stones.add(1, count);
            } else {
                let num_digits = stone.ilog10() + 1;
                if num_digits & 1 == 0 {
                    let factor = 10_i64.pow(num_digits / 2);
                    next_stones.add(stone / factor, count);
                    next_stones.add(stone % factor, count);
                } else {
                    next_stones.add(stone * 2024, count);
                }
            }
        }
        next_stones
    }

    pub fn count(&self) -> i64 {
        self.0.values().sum()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new("125 17");
        assert_eq!(Solution::Num(55312), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day11").unwrap();
        assert_eq!(Solution::Num(224529), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new("125 17");
        assert_eq!(
            Solution::Num(65601038650482),
            solve(Part::Two, input).unwrap()
        );
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day11").unwrap();
        assert_eq!(
            Solution::Num(266820198587914),
            solve(Part::Two, input).unwrap()
        );
    }
}
