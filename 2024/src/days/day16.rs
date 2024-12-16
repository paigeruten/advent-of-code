use std::{
    cmp::Ordering,
    collections::{BinaryHeap, HashMap, HashSet},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let maze = Maze::parse(input)?;

    let solution = match part {
        Part::One => maze.shortest_path_score().unwrap(),
        Part::Two => maze.shortest_path_tiles().unwrap(),
    };

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct Maze {
    spaces: HashSet<Vec2>,
    start: Vec2,
    end: Vec2,
}

impl Maze {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut spaces = HashSet::new();
        let mut start_pos = None;
        let mut end_pos = None;

        for (y, line) in input.lines().enumerate() {
            for (x, ch) in line?.trim().chars().enumerate() {
                if ch == 'S' {
                    start_pos = Some((x, y).into());
                } else if ch == 'E' {
                    end_pos = Some((x, y).into());
                }

                if ch != '#' {
                    spaces.insert((x, y).into());
                }
            }
        }

        Ok(Self {
            spaces,
            start: start_pos.expect("No start tile found"),
            end: end_pos.expect("No end tile found"),
        })
    }

    pub fn shortest_path_score(&self) -> Option<i64> {
        self.shortest_path().map(|(score, _)| score)
    }

    pub fn shortest_path_tiles(&self) -> Option<i64> {
        self.shortest_path().map(|(_, prev)| {
            let mut tiles = HashSet::new();

            let mut queue = vec![
                (self.end, Direction::North),
                (self.end, Direction::East),
                (self.end, Direction::West),
                (self.end, Direction::South),
            ];
            while !queue.is_empty() {
                let mut next_queue = Vec::new();
                for state in queue.drain(..) {
                    tiles.insert(state.0);
                    if let Some(prev_states) = prev.get(&state) {
                        next_queue.extend_from_slice(prev_states);
                    }
                }
                queue = next_queue;
            }

            tiles.len() as i64
        })
    }

    pub fn shortest_path(&self) -> Option<(i64, HashMap<State, Vec<State>>)> {
        let mut dist: HashMap<State, i64> = HashMap::new();
        let mut prev: HashMap<State, Vec<State>> = HashMap::new();
        let mut heap = BinaryHeap::new();
        let mut neighbours_buf = Vec::with_capacity(3);

        let start = (self.start, Direction::East);
        dist.insert(start, 0);
        heap.push(Node {
            cost: 0,
            state: start,
        });

        while let Some(Node { cost, state }) = heap.pop() {
            if state.0 == self.end {
                return Some((cost, prev));
            }

            if cost > *dist.get(&state).unwrap_or(&i64::MAX) {
                continue;
            }

            for neighbour in self.neighbours(state, cost, &mut neighbours_buf) {
                let cost_cmp = neighbour
                    .cost
                    .cmp(dist.get(&neighbour.state).unwrap_or(&i64::MAX));
                if cost_cmp == Ordering::Less {
                    heap.push(*neighbour);
                    dist.insert(neighbour.state, neighbour.cost);
                    prev.insert(neighbour.state, vec![state]);
                } else if cost_cmp == Ordering::Equal {
                    prev.entry(neighbour.state).or_default().push(state);
                }
            }
        }

        None
    }

    fn neighbours<'a>(
        &self,
        state: State,
        base_cost: i64,
        result: &'a mut Vec<Node>,
    ) -> &'a Vec<Node> {
        result.clear();
        let (position, direction) = state;

        let forward_position = position + direction.into();
        if self.spaces.contains(&forward_position) {
            result.push(Node {
                cost: base_cost + 1,
                state: (forward_position, direction),
            });
        }

        let turn_right_position = position + direction.turn_right().into();
        if self.spaces.contains(&turn_right_position) {
            result.push(Node {
                cost: base_cost + 1000,
                state: (position, direction.turn_right()),
            });
        }

        let turn_left_position = position + direction.turn_left().into();
        if self.spaces.contains(&turn_left_position) {
            result.push(Node {
                cost: base_cost + 1000,
                state: (position, direction.turn_left()),
            });
        }

        result
    }
}

type State = (Vec2, Direction);

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Node {
    cost: i64,
    state: State,
}

impl Ord for Node {
    fn cmp(&self, other: &Self) -> Ordering {
        // Order is flipped to make it a min-heap instead of a max-heap.
        other
            .cost
            .cmp(&self.cost)
            .then_with(|| self.state.cmp(&other.state))
    }
}

impl PartialOrd for Node {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
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

    pub fn turn_left(self) -> Self {
        match self {
            Self::North => Self::West,
            Self::East => Self::North,
            Self::South => Self::East,
            Self::West => Self::South,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
struct Vec2 {
    x: i64,
    y: i64,
}

impl From<(usize, usize)> for Vec2 {
    fn from(value: (usize, usize)) -> Self {
        Self {
            x: value.0 as i64,
            y: value.1 as i64,
        }
    }
}

impl From<Direction> for Vec2 {
    fn from(value: Direction) -> Self {
        match value {
            Direction::North => Self { x: 0, y: -1 },
            Direction::East => Self { x: 1, y: 0 },
            Direction::South => Self { x: 0, y: 1 },
            Direction::West => Self { x: -1, y: 0 },
        }
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

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const FIRST_EXAMPLE: &str = "\
        ###############\n\
        #.......#....E#\n\
        #.#.###.#.###.#\n\
        #.....#.#...#.#\n\
        #.###.#####.#.#\n\
        #.#.#.......#.#\n\
        #.#.#####.###.#\n\
        #...........#.#\n\
        ###.#.#####.#.#\n\
        #...#.....#.#.#\n\
        #.#.#.###.#.#.#\n\
        #.....#...#.#.#\n\
        #.###.#.#.#.#.#\n\
        #S..#.....#...#\n\
        ###############\n\
        ";

    const SECOND_EXAMPLE: &str = "\
        #################\n\
        #...#...#...#..E#\n\
        #.#.#.#.#.#.#.#.#\n\
        #.#.#.#...#...#.#\n\
        #.#.#.#.###.#.#.#\n\
        #...#.#.#.....#.#\n\
        #.#.#.#.#.#####.#\n\
        #.#...#.#.#.....#\n\
        #.#.#####.#.###.#\n\
        #.#.#.......#...#\n\
        #.#.###.#####.###\n\
        #.#.#...#.....#.#\n\
        #.#.#.#####.###.#\n\
        #.#.#.........#.#\n\
        #.#.#.#########.#\n\
        #S#.............#\n\
        #################\n\
        ";

    #[test]
    fn solve_part_one_example_one() {
        let input = Cursor::new(FIRST_EXAMPLE);
        assert_eq!(Solution::Num(7036), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one_example_two() {
        let input = Cursor::new(SECOND_EXAMPLE);
        assert_eq!(Solution::Num(11048), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day16").unwrap();
        assert_eq!(Solution::Num(115500), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example_one() {
        let input = Cursor::new(FIRST_EXAMPLE);
        assert_eq!(Solution::Num(45), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two_example_two() {
        let input = Cursor::new(SECOND_EXAMPLE);
        assert_eq!(Solution::Num(64), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day16").unwrap();
        assert_eq!(Solution::Num(679), solve(Part::Two, input).unwrap());
    }
}
