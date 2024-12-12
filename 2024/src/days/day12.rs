use std::{
    collections::{HashMap, HashSet, VecDeque},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let solution = Farm::parse(input)?
        .regions()
        .iter()
        .map(|region| match part {
            Part::One => region.area() * region.perimeter(),
            Part::Two => region.area() * region.count_sides(),
        })
        .sum();

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct Farm {
    width: i64,
    height: i64,
    grid: Vec<Vec<char>>,
}

impl Farm {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let grid: Vec<Vec<char>> = input
            .lines()
            .filter_map(|line| line.ok().map(|line| line.chars().collect()))
            .collect();

        Ok(Self {
            width: grid[0].len() as i64,
            height: grid.len() as i64,
            grid,
        })
    }

    pub fn get(&self, position: Vec2) -> Option<char> {
        self.grid
            .get(position.y as usize)
            .and_then(|row| row.get(position.x as usize))
            .copied()
    }

    pub fn regions(&self) -> Vec<Region> {
        let mut regions = Vec::new();
        let mut visited = HashSet::new();

        for y in 0..self.height {
            for x in 0..self.width {
                let pos = Vec2 { x, y };
                if visited.contains(&pos) {
                    continue;
                }

                let plant = self.get(pos).unwrap();
                let mut region = Region::new();
                let mut queue = VecDeque::from([pos]);
                while let Some(cur) = queue.pop_front() {
                    let mut fences = Fences::new();
                    for direction in Direction::ALL {
                        let neighbor_pos = cur + direction.as_vector();
                        if self.get(neighbor_pos) == Some(plant) {
                            if !visited.contains(&neighbor_pos) {
                                visited.insert(neighbor_pos);
                                queue.push_back(neighbor_pos);
                            }
                        } else {
                            match direction {
                                Direction::North => fences.north = true,
                                Direction::West => fences.west = true,
                                Direction::South => fences.south = true,
                                Direction::East => fences.east = true,
                            }
                        }
                    }
                    region.add_plot(cur, fences);
                }
                regions.push(region);
            }
        }

        regions
    }
}

#[derive(Debug)]
struct Region {
    plots: HashMap<Vec2, Fences>,
}

impl Region {
    pub fn new() -> Self {
        Self {
            plots: HashMap::new(),
        }
    }

    pub fn add_plot(&mut self, position: Vec2, fences: Fences) {
        self.plots.insert(position, fences);
    }

    pub fn area(&self) -> i64 {
        self.plots.len() as i64
    }

    pub fn perimeter(&self) -> i64 {
        self.plots.values().map(|fences| fences.count()).sum()
    }

    pub fn count_sides(&self) -> i64 {
        Direction::ALL
            .into_iter()
            .map(|direction| self.count_sides_for_direction(direction))
            .sum()
    }

    fn count_sides_for_direction(&self, direction: Direction) -> i64 {
        let mut edges_by_line: HashMap<i64, Vec<i64>> = HashMap::new();
        for (&edge, _) in self
            .plots
            .iter()
            .filter(|(_, fences)| fences.contains(direction))
        {
            if direction.is_vertical() {
                edges_by_line.entry(edge.y).or_default().push(edge.x);
            } else {
                edges_by_line.entry(edge.x).or_default().push(edge.y);
            }
        }

        let mut num_sides = 0;
        for xs in edges_by_line.values_mut() {
            xs.sort();

            let mut last_x = None;
            for &x in xs.iter() {
                if last_x != Some(x - 1) {
                    num_sides += 1;
                }
                last_x = Some(x);
            }
        }
        num_sides
    }
}

#[derive(Debug, Default)]
struct Fences {
    north: bool,
    west: bool,
    south: bool,
    east: bool,
}

impl Fences {
    pub fn new() -> Self {
        Fences::default()
    }

    pub fn count(&self) -> i64 {
        self.north as i64 + self.west as i64 + self.south as i64 + self.east as i64
    }

    pub fn contains(&self, direction: Direction) -> bool {
        match direction {
            Direction::North => self.north,
            Direction::West => self.west,
            Direction::South => self.south,
            Direction::East => self.east,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Vec2 {
    x: i64,
    y: i64,
}

impl std::ops::Add for Vec2 {
    type Output = Self;

    fn add(self, rhs: Self) -> Self::Output {
        Self {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Direction {
    North,
    West,
    South,
    East,
}

impl Direction {
    pub const ALL: [Self; 4] = [Self::North, Self::West, Self::South, Self::East];

    pub fn as_vector(self) -> Vec2 {
        match self {
            Self::North => Vec2 { x: 0, y: -1 },
            Self::West => Vec2 { x: -1, y: 0 },
            Self::South => Vec2 { x: 0, y: 1 },
            Self::East => Vec2 { x: 1, y: 0 },
        }
    }

    pub fn is_vertical(self) -> bool {
        self == Self::North || self == Self::South
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    #[test]
    fn solve_part_one_example_one() {
        let input = Cursor::new(
            "\
            AAAA\n\
            BBCD\n\
            BBCC\n\
            EEEC\n\
            ",
        );
        assert_eq!(Solution::Num(140), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one_example_two() {
        let input = Cursor::new(
            "\
            OOOOO\n\
            OXOXO\n\
            OOOOO\n\
            OXOXO\n\
            OOOOO\n\
            ",
        );
        assert_eq!(Solution::Num(772), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one_example_three() {
        let input = Cursor::new(
            "\
            RRRRIICCFF\n\
            RRRRIICCCF\n\
            VVRRRCCFFF\n\
            VVRCCCJFFF\n\
            VVVVCJJCFE\n\
            VVIVCCJJEE\n\
            VVIIICJJEE\n\
            MIIIIIJJEE\n\
            MIIISIJEEE\n\
            MMMISSJEEE\n\
            ",
        );
        assert_eq!(Solution::Num(1930), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day12").unwrap();
        assert_eq!(Solution::Num(1473276), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example_one() {
        let input = Cursor::new(
            "\
            AAAA\n\
            BBCD\n\
            BBCC\n\
            EEEC\n\
            ",
        );
        assert_eq!(Solution::Num(80), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two_example_two() {
        let input = Cursor::new(
            "\
            OOOOO\n\
            OXOXO\n\
            OOOOO\n\
            OXOXO\n\
            OOOOO\n\
            ",
        );
        assert_eq!(Solution::Num(436), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two_example_three() {
        let input = Cursor::new(
            "\
            EEEEE\n\
            EXXXX\n\
            EEEEE\n\
            EXXXX\n\
            EEEEE\n\
            ",
        );
        assert_eq!(Solution::Num(236), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two_example_four() {
        let input = Cursor::new(
            "\
            AAAAAA\n\
            AAABBA\n\
            AAABBA\n\
            ABBAAA\n\
            ABBAAA\n\
            AAAAAA\n\
            ",
        );
        assert_eq!(Solution::Num(368), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day12").unwrap();
        assert_eq!(Solution::Num(901100), solve(Part::Two, input).unwrap());
    }
}
