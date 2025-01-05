use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let (locks, keys) = parse(input)?;

    Ok(match part {
        Part::One => {
            let mut num_fit = 0;
            for lock in locks.iter() {
                for key in keys.iter() {
                    if key.fits_in(lock) {
                        num_fit += 1;
                    }
                }
            }
            Solution::Num(num_fit)
        }
        Part::Two => Solution::Str("n/a".into()),
    })
}

fn parse(input: impl BufRead) -> color_eyre::Result<(Vec<PinHeights>, Vec<PinHeights>)> {
    let mut locks = Vec::new();
    let mut keys = Vec::new();

    let mut lines = input.lines();
    while let Some(first_line) = lines.next() {
        let first_line = first_line?;
        let mut heights = vec![0; first_line.len()];
        let mut max_height = -1;
        let is_lock = first_line.starts_with('#');

        for line in lines.by_ref() {
            let line = line?;
            if line.is_empty() {
                break;
            }

            for (idx, ch) in line.chars().enumerate() {
                if ch == '#' {
                    heights[idx] += 1;
                }
            }

            max_height += 1;
        }

        if is_lock {
            locks.push(PinHeights {
                max_height,
                heights,
            });
        } else {
            // Ignore last row of key
            for height in heights.iter_mut() {
                *height -= 1;
            }

            keys.push(PinHeights {
                max_height,
                heights,
            });
        }
    }

    Ok((locks, keys))
}

#[derive(Debug)]
struct PinHeights {
    max_height: i8,
    heights: Vec<i8>,
}

impl PinHeights {
    pub fn fits_in(&self, other: &PinHeights) -> bool {
        if self.max_height != other.max_height || self.heights.len() != other.heights.len() {
            return false;
        }

        self.heights
            .iter()
            .zip(other.heights.iter())
            .all(|(a, b)| a + b <= self.max_height)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        #####\n\
        .####\n\
        .####\n\
        .####\n\
        .#.#.\n\
        .#...\n\
        .....\n\
        \n\
        #####\n\
        ##.##\n\
        .#.##\n\
        ...##\n\
        ...#.\n\
        ...#.\n\
        .....\n\
        \n\
        .....\n\
        #....\n\
        #....\n\
        #...#\n\
        #.#.#\n\
        #.###\n\
        #####\n\
        \n\
        .....\n\
        .....\n\
        #.#..\n\
        ###..\n\
        ###.#\n\
        ###.#\n\
        #####\n\
        \n\
        .....\n\
        .....\n\
        .....\n\
        #....\n\
        #.#..\n\
        #.#.#\n\
        #####\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(3), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day25").unwrap();
        assert_eq!(Solution::Num(3356), solve(Part::One, input).unwrap());
    }
}
