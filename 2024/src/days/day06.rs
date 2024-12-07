use std::{
    collections::{HashMap, HashSet},
    fmt::Display,
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let solution = match part {
        Part::One => {
            let mut world = World::parse(input)?;
            world.simulate();
            world.guard.positions_been().len()
        }

        Part::Two => {
            let initial_world = World::parse(input)?;

            let mut world = initial_world.clone();
            world.simulate();

            world
                .guard
                .positions_been()
                .into_iter()
                .filter(|&new_obstruction| {
                    if new_obstruction == initial_world.guard.position {
                        return false;
                    }

                    let mut cur_world = initial_world.clone();
                    cur_world.add_obstruction(new_obstruction);
                    cur_world.fast_simulate() == SimulationResult::LoopDetected
                })
                .count()
        }
    };

    Ok(Solution::Num(solution as i64))
}

#[derive(Debug, Clone)]
struct World {
    width: i64,
    height: i64,
    obstructions: HashSet<Position>,
    obstructions_by_x: HashMap<i64, Vec<Position>>,
    obstructions_by_y: HashMap<i64, Vec<Position>>,
    guard: Guard,
}

impl World {
    pub fn new(width: i64, height: i64, obstructions: HashSet<Position>, guard: Guard) -> Self {
        let mut obstructions_by_x: HashMap<i64, Vec<Position>> = HashMap::new();
        let mut obstructions_by_y: HashMap<i64, Vec<Position>> = HashMap::new();
        for &obstruction in obstructions.iter() {
            obstructions_by_x
                .entry(obstruction.x)
                .or_default()
                .push(obstruction);
            obstructions_by_y
                .entry(obstruction.y)
                .or_default()
                .push(obstruction);
        }

        for positions in obstructions_by_x.values_mut() {
            positions.sort_by_key(|pos| pos.y);
        }
        for positions in obstructions_by_y.values_mut() {
            positions.sort_by_key(|pos| pos.x);
        }

        Self {
            width,
            height,
            obstructions,
            obstructions_by_x,
            obstructions_by_y,
            guard,
        }
    }

    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut width = 0;
        let mut height = 0;
        let mut obstructions = HashSet::new();
        let mut guard = Guard::new();

        for line in input.lines() {
            let line = line?;

            for (x, ch) in line.chars().enumerate() {
                let position = Position {
                    x: x as i64,
                    y: height,
                };

                if ch == '#' {
                    obstructions.insert(position);
                } else if let Ok(direction) = ch.try_into() {
                    guard.position = position;
                    guard.facing = direction;
                }
            }

            width = width.max(line.len() as i64);
            height += 1;
        }

        Ok(World::new(width, height, obstructions, guard))
    }

    pub fn add_obstruction(&mut self, obstruction: Position) {
        self.obstructions.insert(obstruction);

        let by_x = self.obstructions_by_x.entry(obstruction.x).or_default();
        by_x.push(obstruction);
        by_x.sort_by_key(|pos| pos.y);

        let by_y = self.obstructions_by_y.entry(obstruction.y).or_default();
        by_y.push(obstruction);
        by_y.sort_by_key(|pos| pos.x);
    }

    pub fn simulate(&mut self) -> SimulationResult {
        loop {
            if let Some(result) = self.step() {
                return result;
            }
        }
    }

    pub fn fast_simulate(&mut self) -> SimulationResult {
        loop {
            if let Some(result) = self.leap() {
                return result;
            }
        }
    }

    fn step(&mut self) -> Option<SimulationResult> {
        self.guard
            .been
            .insert((self.guard.position, self.guard.facing));

        let next_position = self.guard.position.step_forward(self.guard.facing);
        if self.obstructions.contains(&next_position) {
            self.guard.facing = self.guard.facing.turn_right();
        } else if self
            .guard
            .been
            .contains(&(next_position, self.guard.facing))
        {
            return Some(SimulationResult::LoopDetected);
        } else {
            self.guard.position = next_position;
            if !self.guard.position.is_in_bounds(self.width, self.height) {
                return Some(SimulationResult::OutOfBounds);
            }
        }

        None
    }

    fn leap(&mut self) -> Option<SimulationResult> {
        self.guard
            .been
            .insert((self.guard.position, self.guard.facing));

        if let Some(obstruction) = self.find_next_obstruction() {
            self.guard.position = obstruction.step_forward(self.guard.facing.opposite());
            self.guard.facing = self.guard.facing.turn_right();

            if self
                .guard
                .been
                .contains(&(self.guard.position, self.guard.facing))
            {
                Some(SimulationResult::LoopDetected)
            } else {
                None
            }
        } else {
            Some(SimulationResult::OutOfBounds)
        }
    }

    fn find_next_obstruction(&self) -> Option<Position> {
        match self.guard.facing {
            Direction::North => {
                self.obstructions_by_x
                    .get(&self.guard.position.x)
                    .and_then(|obstructions| {
                        obstructions
                            .iter()
                            .rev()
                            .find(|obstruction| obstruction.y < self.guard.position.y)
                    })
            }
            Direction::South => {
                self.obstructions_by_x
                    .get(&self.guard.position.x)
                    .and_then(|obstructions| {
                        obstructions
                            .iter()
                            .find(|obstruction| obstruction.y > self.guard.position.y)
                    })
            }
            Direction::West => {
                self.obstructions_by_y
                    .get(&self.guard.position.y)
                    .and_then(|obstructions| {
                        obstructions
                            .iter()
                            .rev()
                            .find(|obstruction| obstruction.x < self.guard.position.x)
                    })
            }
            Direction::East => {
                self.obstructions_by_y
                    .get(&self.guard.position.y)
                    .and_then(|obstructions| {
                        obstructions
                            .iter()
                            .find(|obstruction| obstruction.x > self.guard.position.x)
                    })
            }
        }
        .copied()
    }
}

#[derive(Debug, PartialEq)]
enum SimulationResult {
    LoopDetected,
    OutOfBounds,
}

#[derive(Debug, Clone)]
struct Guard {
    position: Position,
    facing: Direction,
    been: HashSet<(Position, Direction)>,
}

impl Guard {
    pub fn new() -> Self {
        Self {
            position: Position { x: 0, y: 0 },
            facing: Direction::North,
            been: HashSet::new(),
        }
    }

    pub fn positions_been(&self) -> HashSet<Position> {
        self.been.iter().map(|&(position, _)| position).collect()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Position {
    x: i64,
    y: i64,
}

impl Position {
    pub fn step_forward(self, direction: Direction) -> Position {
        match direction {
            Direction::North => Position {
                y: self.y - 1,
                ..self
            },
            Direction::East => Position {
                x: self.x + 1,
                ..self
            },
            Direction::South => Position {
                y: self.y + 1,
                ..self
            },
            Direction::West => Position {
                x: self.x - 1,
                ..self
            },
        }
    }

    pub fn is_in_bounds(&self, width: i64, height: i64) -> bool {
        (0..width).contains(&self.x) && (0..height).contains(&self.y)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Direction {
    North,
    East,
    South,
    West,
}

impl Direction {
    pub fn turn_right(self) -> Self {
        match self {
            Self::North => Self::East,
            Self::East => Self::South,
            Self::South => Self::West,
            Self::West => Self::North,
        }
    }

    pub fn opposite(self) -> Self {
        match self {
            Self::North => Self::South,
            Self::East => Self::West,
            Self::South => Self::North,
            Self::West => Self::East,
        }
    }
}

impl Display for Direction {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Self::North => '^',
                Self::East => '>',
                Self::South => 'v',
                Self::West => '<',
            }
        )
    }
}

impl TryFrom<char> for Direction {
    type Error = ();

    fn try_from(value: char) -> Result<Self, Self::Error> {
        match value {
            '^' => Ok(Self::North),
            '>' => Ok(Self::East),
            'v' => Ok(Self::South),
            '<' => Ok(Self::West),
            _ => Err(()),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        ....#.....\n\
        .........#\n\
        ..........\n\
        ..#.......\n\
        .......#..\n\
        ..........\n\
        .#..^.....\n\
        ........#.\n\
        #.........\n\
        ......#...\n\
    ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(41), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day06").unwrap();
        assert_eq!(Solution::Num(5208), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(6), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day06").unwrap();
        assert_eq!(Solution::Num(1972), solve(Part::Two, input).unwrap());
    }
}
