use std::{
    collections::{HashMap, HashSet},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let race_track = RaceTrack::parse(input)?;

    let solution = match part {
        Part::One => race_track.count_cheats(2, 100),
        Part::Two => race_track.count_cheats(20, 100),
    };

    Ok(Solution::Num(solution))
}

const DIRECTIONS: [(i64, i64); 4] = [(0, -1), (1, 0), (0, 1), (-1, 0)];

#[derive(Debug)]
struct RaceTrack {
    /// Each point on the racetrack, starting with 'S' and ending with 'E'
    track: Vec<Vec2>,
    /// How far along the racetrack a given point is (the inverse of `track`)
    spaces: HashMap<Vec2, usize>,
}

impl RaceTrack {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut start_pos: Option<Vec2> = None;
        let mut end_pos: Option<Vec2> = None;

        // First parse to a 2D array
        let mut grid: Vec<Vec<char>> = Vec::new();
        for (y, line) in input.lines().enumerate() {
            grid.push(line?.trim().chars().collect());
            for (x, &ch) in grid.last().unwrap().iter().enumerate() {
                if ch == 'S' {
                    start_pos = Some((x, y).into());
                } else if ch == 'E' {
                    end_pos = Some((x, y).into());
                }
            }
        }
        let width = grid[0].len() as i64;
        let height = grid.len() as i64;

        // Now follow the racetrack
        let mut track = Vec::new();
        let mut spaces = HashMap::new();
        let mut pos = start_pos.unwrap();
        loop {
            track.push(pos);
            spaces.insert(pos, track.len() - 1);

            if Some(pos) == end_pos {
                break;
            }

            let mut next_pos = pos;
            for (dx, dy) in DIRECTIONS {
                let neighbour = Vec2 {
                    x: pos.x + dx,
                    y: pos.y + dy,
                };
                if (0..width).contains(&neighbour.x)
                    && (0..height).contains(&neighbour.y)
                    && grid[neighbour.y as usize][neighbour.x as usize] != '#'
                    && !spaces.contains_key(&neighbour)
                {
                    next_pos = neighbour;
                }
            }

            if next_pos == pos {
                panic!("Unexpected dead end");
            }
            pos = next_pos;
        }

        Ok(Self { track, spaces })
    }

    pub fn count_cheats(&self, max_cheat: i64, threshold: i64) -> i64 {
        let cheat_area = points_in_circle(max_cheat);

        let mut num_cheats = 0;
        for idx in 0..(self.track.len() - 1) {
            let cheat_start = self.track[idx];
            for cheat_end in cheat_area.iter().map(|&delta| cheat_start + delta) {
                if let Some(&end_idx) = self.spaces.get(&cheat_end) {
                    let cheat_length = cheat_end.manhattan_distance(cheat_start);
                    let savings = end_idx as i64 - idx as i64 - cheat_length + 1;
                    if savings >= threshold {
                        num_cheats += 1;
                    }
                }
            }
        }
        num_cheats
    }
}

fn points_in_circle(radius: i64) -> Vec<Vec2> {
    let mut points = HashSet::new();

    let mut frontier = vec![Vec2 { x: 0, y: 0 }];
    for _ in 0..radius {
        let mut next_frontier = Vec::new();
        for pos in frontier.iter() {
            for (dx, dy) in DIRECTIONS {
                let neighbour = Vec2 {
                    x: pos.x + dx,
                    y: pos.y + dy,
                };
                if !points.contains(&neighbour) {
                    points.insert(neighbour);
                    next_frontier.push(neighbour);
                }
            }
        }
        frontier = next_frontier;
    }

    points.into_iter().collect()
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct Vec2 {
    x: i64,
    y: i64,
}

impl Vec2 {
    pub fn manhattan_distance(self, other: Vec2) -> i64 {
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }
}

impl From<(usize, usize)> for Vec2 {
    fn from(value: (usize, usize)) -> Self {
        Self {
            x: value.0 as i64,
            y: value.1 as i64,
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

    const EXAMPLE_INPUT: &str = "\
        ###############\n\
        #...#...#.....#\n\
        #.#.#.#.#.###.#\n\
        #S#...#.#.#...#\n\
        #######.#.#.###\n\
        #######.#.#...#\n\
        #######.#.###.#\n\
        ###..E#...#...#\n\
        ###.#######.###\n\
        #...###...#...#\n\
        #.#####.#.###.#\n\
        #.#...#.#.#...#\n\
        #.#.#.#.#.#.###\n\
        #...#...#...###\n\
        ###############\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        let race_track = RaceTrack::parse(input).unwrap();
        assert_eq!(10, race_track.count_cheats(2, 10));
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day20").unwrap();
        assert_eq!(Solution::Num(1502), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        let race_track = RaceTrack::parse(input).unwrap();
        assert_eq!(41, race_track.count_cheats(20, 70));
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day20").unwrap();
        assert_eq!(Solution::Num(1028136), solve(Part::Two, input).unwrap());
    }
}
