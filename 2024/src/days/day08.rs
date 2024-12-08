use std::{
    collections::{HashMap, HashSet},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let world = World::parse(input)?;

    let solution = match part {
        Part::One => world.count_antinodes(false),
        Part::Two => world.count_antinodes(true),
    };

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct World {
    width: i64,
    height: i64,
    antennae: HashMap<char, Vec<Position>>,
}

impl World {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut width = 0;
        let mut height = 0;
        let mut antennae = HashMap::new();

        for line in input.lines() {
            let line = line?;

            for (x, frequency) in line.chars().enumerate() {
                if frequency != '.' {
                    antennae
                        .entry(frequency)
                        .or_insert_with(Vec::new)
                        .push(Position {
                            x: x as i64,
                            y: height,
                        });
                }
            }

            width = width.max(line.len() as i64);
            height += 1;
        }

        Ok(World {
            width,
            height,
            antennae,
        })
    }

    pub fn count_antinodes(&self, all: bool) -> i64 {
        let mut antinodes = HashSet::new();

        for positions in self.antennae.values() {
            for i in 0..(positions.len() - 1) {
                for j in (i + 1)..positions.len() {
                    let (mut negative, mut positive) =
                        self.find_antinodes(positions[i], positions[j]);

                    let found_antinodes: Vec<_> = if all {
                        negative.chain(positive).collect()
                    } else {
                        [negative.nth(1), positive.nth(1)]
                            .into_iter()
                            .flatten()
                            .collect()
                    };

                    for antinode in found_antinodes.into_iter() {
                        antinodes.insert(antinode);
                    }
                }
            }
        }

        antinodes.len() as i64
    }

    fn find_antinodes(
        &self,
        pos_a: Position,
        pos_b: Position,
    ) -> (
        impl Iterator<Item = Position> + '_,
        impl Iterator<Item = Position> + '_,
    ) {
        let (dx, dy) = (pos_b.x - pos_a.x, pos_b.y - pos_a.y);

        let negative_antinodes = std::iter::successors(Some(pos_a), move |Position { x, y }| {
            Some(Position {
                x: x - dx,
                y: y - dy,
            })
        })
        .take_while(|pos| self.in_bounds(pos));

        let positive_antinodes = std::iter::successors(Some(pos_b), move |Position { x, y }| {
            Some(Position {
                x: x + dx,
                y: y + dy,
            })
        })
        .take_while(|pos| self.in_bounds(pos));

        (negative_antinodes, positive_antinodes)
    }

    fn in_bounds(&self, Position { x, y }: &Position) -> bool {
        (0..self.width).contains(x) && (0..self.height).contains(y)
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
        ............\n\
        ........0...\n\
        .....0......\n\
        .......0....\n\
        ....0.......\n\
        ......A.....\n\
        ............\n\
        ............\n\
        ........A...\n\
        .........A..\n\
        ............\n\
        ............\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(14), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day08").unwrap();
        assert_eq!(Solution::Num(348), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(34), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day08").unwrap();
        assert_eq!(Solution::Num(1221), solve(Part::Two, input).unwrap());
    }
}
