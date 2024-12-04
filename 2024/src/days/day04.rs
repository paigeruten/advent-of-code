use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let word_search = WordSearch::parse(input);

    let solution = match part {
        Part::One => word_search.count_xmas(),
        Part::Two => word_search.count_x_mas(),
    };

    Ok(Solution::Num(solution as i64))
}

struct WordSearch {
    grid: Vec<Vec<char>>,
    width: usize,
    height: usize,
}

impl WordSearch {
    pub fn parse(input: impl BufRead) -> Self {
        let grid: Vec<Vec<char>> = input
            .lines()
            .map(|line| line.unwrap().chars().collect())
            .collect();

        let width = grid[0].len();
        let height = grid.len();

        Self {
            grid,
            width,
            height,
        }
    }

    fn directional_get(
        &self,
        x: isize,
        y: isize,
        (dx, dy): (isize, isize),
        length: usize,
    ) -> Option<char> {
        let (cx, cy) = (x + dx * length as isize, y + dy * length as isize);
        if cx < 0 || cy < 0 {
            return None;
        }
        self.grid
            .get(cy as usize)
            .and_then(|row| row.get(cx as usize))
            .copied()
    }

    pub fn count_xmas(&self) -> usize {
        const DIRECTIONS: [(isize, isize); 8] = [
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1),
        ];

        let mut num_found = 0;
        for y in 0..self.height as isize {
            for x in 0..self.width as isize {
                num_found += DIRECTIONS
                    .iter()
                    .filter(|&&direction| {
                        "XMAS".chars().enumerate().all(|(index, letter)| {
                            self.directional_get(x, y, direction, index) == Some(letter)
                        })
                    })
                    .count();
            }
        }
        num_found
    }

    pub fn count_x_mas(&self) -> usize {
        const INNER: char = 'A';
        const OUTERS: [(char, char); 2] = [('M', 'S'), ('S', 'M')];

        let mut num_found = 0;
        for y in 1..(self.height - 1) {
            for x in 1..(self.width - 1) {
                if self.grid[y][x] != INNER {
                    continue;
                }

                let (top_left, top_right, bottom_left, bottom_right) = (
                    self.grid[y - 1][x - 1],
                    self.grid[y - 1][x + 1],
                    self.grid[y + 1][x - 1],
                    self.grid[y + 1][x + 1],
                );

                if OUTERS.contains(&(bottom_left, top_right))
                    && OUTERS.contains(&(top_left, bottom_right))
                {
                    num_found += 1;
                }
            }
        }
        num_found
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        MMMSXXMASM\n\
        MSAMXMSMSA\n\
        AMXSXMAAMM\n\
        MSAMASMSMX\n\
        XMASAMXAMM\n\
        XXAMMXXAMA\n\
        SMSMSASXSS\n\
        SAXAMASAAA\n\
        MAMMMXMMMM\n\
        MXMXAXMASX\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(18), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day04").unwrap();
        assert_eq!(Solution::Num(2462), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(9), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day04").unwrap();
        assert_eq!(Solution::Num(1877), solve(Part::Two, input).unwrap());
    }
}
