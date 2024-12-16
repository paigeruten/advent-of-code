use std::{collections::HashSet, fmt::Display, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let mut warehouse = Warehouse::parse(input)?;

    if part == Part::Two {
        warehouse.widen();
    }

    warehouse.simulate();

    let boxes = match part {
        Part::One => warehouse.find_tiles(Tile::Box),
        Part::Two => warehouse.find_tiles(Tile::WideBoxLeft),
    };

    let solution = boxes
        .into_iter()
        .map(|position| position.gps_coordinate())
        .sum();

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct Warehouse {
    grid: Vec<Vec<Tile>>,
    robot: Robot,
}

impl Warehouse {
    pub fn parse(mut input: impl BufRead) -> color_eyre::Result<Self> {
        let mut grid = Vec::new();
        let mut robot = Robot::default();

        let mut line = String::new();
        let mut y = 0;
        loop {
            line.clear();
            input.read_line(&mut line)?;

            if line.trim_ascii_end().is_empty() {
                break;
            }

            grid.push(
                line.trim_ascii_end()
                    .chars()
                    .enumerate()
                    .filter_map(|(x, ch)| {
                        let tile = ch.try_into().ok();
                        if tile == Some(Tile::Robot) {
                            robot.position.x = x as i64;
                            robot.position.y = y;
                        }
                        tile
                    })
                    .collect(),
            );
            y += 1;
        }

        line.clear();
        input.read_to_string(&mut line)?;
        robot.instructions = line.chars().filter_map(|ch| ch.try_into().ok()).collect();

        Ok(Self { grid, robot })
    }

    pub fn widen(&mut self) {
        self.robot.position.x *= 2;

        self.grid = self
            .grid
            .iter()
            .map(|row| {
                row.iter()
                    .flat_map(|&tile| match tile {
                        Tile::Box => [Tile::WideBoxLeft, Tile::WideBoxRight],
                        Tile::Robot => [Tile::Robot, Tile::Empty],
                        tile => [tile, tile],
                    })
                    .collect()
            })
            .collect();
    }

    pub fn get(&self, position: Vec2) -> Tile {
        self.grid[position.y as usize][position.x as usize]
    }

    pub fn set(&mut self, position: Vec2, tile: Tile) {
        self.grid[position.y as usize][position.x as usize] = tile;
    }

    pub fn simulate(&mut self) {
        for &instruction in self.robot.instructions.clone().iter() {
            self.move_robot(instruction);
        }
    }

    #[allow(dead_code)]
    pub fn simulate_interactive(&mut self) {
        println!("\n{}", self);
        print!("\n> ");

        let stdin = std::io::stdin();
        for line in stdin.lock().lines() {
            let instruction = match line.unwrap().trim() {
                "h" => Instruction::West,
                "j" => Instruction::South,
                "k" => Instruction::North,
                "l" => Instruction::East,
                _ => return,
            };
            self.move_robot(instruction);

            println!("\n{}", self);
            print!("\n> ");
        }
    }

    pub fn move_robot(&mut self, instruction: Instruction) {
        let direction = match instruction {
            Instruction::North => Vec2 { x: 0, y: -1 },
            Instruction::East => Vec2 { x: 1, y: 0 },
            Instruction::South => Vec2 { x: 0, y: 1 },
            Instruction::West => Vec2 { x: -1, y: 0 },
        };

        let target = self.robot.position + direction;
        let can_move = match self.get(target) {
            Tile::Empty => true,
            Tile::Box => self.push_box(direction),
            Tile::WideBoxLeft | Tile::WideBoxRight => {
                if direction.y == 0 {
                    self.push_box(direction)
                } else {
                    self.push_wide_box_vertically(direction)
                }
            }
            Tile::Wall => false,
            Tile::Robot => panic!("Did not expect another robot"),
        };

        if can_move {
            self.set(self.robot.position, Tile::Empty);
            self.robot.position = target;
            self.set(self.robot.position, Tile::Robot);
        }
    }

    fn push_box(&mut self, direction: Vec2) -> bool {
        let target = self.robot.position + direction;
        let mut cur = target;
        loop {
            cur += direction;
            match self.get(cur) {
                Tile::Empty => break,
                Tile::Wall => return false,
                _ => {}
            }
        }

        while cur != self.robot.position {
            self.set(cur, self.get(cur - direction));
            cur -= direction;
        }

        true
    }

    fn push_wide_box_vertically(&mut self, direction: Vec2) -> bool {
        let mut boxes_by_row = vec![HashSet::from([self.robot.position])];
        loop {
            let mut next_row = HashSet::new();

            for &pos in boxes_by_row.last().unwrap() {
                let target_pos = pos + direction;
                match self.get(target_pos) {
                    Tile::Wall => return false,
                    Tile::WideBoxLeft => {
                        next_row.insert(target_pos);
                        next_row.insert(target_pos + Vec2 { x: 1, y: 0 });
                    }
                    Tile::WideBoxRight => {
                        next_row.insert(target_pos);
                        next_row.insert(target_pos + Vec2 { x: -1, y: 0 });
                    }
                    Tile::Empty => {}
                    Tile::Robot | Tile::Box => unreachable!(),
                }
            }

            if next_row.is_empty() {
                break;
            } else {
                boxes_by_row.push(next_row);
            }
        }

        for boxes_in_row in boxes_by_row.iter().rev() {
            for &pos in boxes_in_row {
                self.set(pos + direction, self.get(pos));
                self.set(pos, Tile::Empty);
            }
        }

        true
    }

    pub fn find_tiles(&self, tile: Tile) -> Vec<Vec2> {
        let mut result = Vec::new();
        for (y, row) in self.grid.iter().enumerate() {
            for (x, &cur_tile) in row.iter().enumerate() {
                if cur_tile == tile {
                    result.push(Vec2 {
                        x: x as i64,
                        y: y as i64,
                    });
                }
            }
        }
        result
    }
}

impl Display for Warehouse {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        for row in self.grid.iter() {
            writeln!(
                f,
                "{}",
                row.iter().copied().map(char::from).collect::<String>()
            )?;
        }
        Ok(())
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Tile {
    Empty,
    Wall,
    Box,
    WideBoxLeft,
    WideBoxRight,
    Robot,
}

impl TryFrom<char> for Tile {
    type Error = ();

    fn try_from(value: char) -> Result<Self, Self::Error> {
        Ok(match value {
            '.' => Self::Empty,
            '#' => Self::Wall,
            'O' => Self::Box,
            '@' => Self::Robot,
            _ => return Err(()),
        })
    }
}

impl From<Tile> for char {
    fn from(value: Tile) -> char {
        match value {
            Tile::Empty => '.',
            Tile::Wall => '#',
            Tile::Box => 'O',
            Tile::WideBoxLeft => '[',
            Tile::WideBoxRight => ']',
            Tile::Robot => '@',
        }
    }
}

#[derive(Debug, Default)]
struct Robot {
    position: Vec2,
    instructions: Vec<Instruction>,
}

#[derive(Debug, Clone, Copy)]
enum Instruction {
    North,
    East,
    South,
    West,
}

impl TryFrom<char> for Instruction {
    type Error = ();

    fn try_from(value: char) -> Result<Self, Self::Error> {
        Ok(match value {
            '^' => Self::North,
            '>' => Self::East,
            'v' => Self::South,
            '<' => Self::West,
            _ => return Err(()),
        })
    }
}

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq, Hash)]
struct Vec2 {
    x: i64,
    y: i64,
}

impl Vec2 {
    pub fn gps_coordinate(&self) -> i64 {
        self.y * 100 + self.x
    }
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

impl std::ops::AddAssign for Vec2 {
    fn add_assign(&mut self, rhs: Self) {
        *self = *self + rhs;
    }
}

impl std::ops::Sub for Vec2 {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self::Output {
        Self {
            x: self.x - rhs.x,
            y: self.y - rhs.y,
        }
    }
}

impl std::ops::SubAssign for Vec2 {
    fn sub_assign(&mut self, rhs: Self) {
        *self = *self - rhs;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const SMALL_EXAMPLE: &str = "\
        ########\n\
        #..O.O.#\n\
        ##@.O..#\n\
        #...O..#\n\
        #.#.O..#\n\
        #...O..#\n\
        #......#\n\
        ########\n\
        \n\
        <^^>>>vv<v>>v<<\n\
        ";

    const LARGE_EXAMPLE: &str = "\
        ##########\n\
        #..O..O.O#\n\
        #......O.#\n\
        #.OO..O.O#\n\
        #..O@..O.#\n\
        #O#..O...#\n\
        #O..O..O.#\n\
        #.OO.O.OO#\n\
        #....O...#\n\
        ##########\n\
        \n\
        <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^\n\
        vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v\n\
        ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<\n\
        <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^\n\
        ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><\n\
        ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^\n\
        >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^\n\
        <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>\n\
        ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>\n\
        v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^\n\
        ";

    #[test]
    fn solve_part_one_small_example() {
        let input = Cursor::new(SMALL_EXAMPLE);
        assert_eq!(Solution::Num(2028), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one_large_example() {
        let input = Cursor::new(LARGE_EXAMPLE);
        assert_eq!(Solution::Num(10092), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day15").unwrap();
        assert_eq!(Solution::Num(1415498), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_large_example() {
        let input = Cursor::new(LARGE_EXAMPLE);
        assert_eq!(Solution::Num(9021), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day15").unwrap();
        assert_eq!(Solution::Num(1432898), solve(Part::Two, input).unwrap());
    }
}
