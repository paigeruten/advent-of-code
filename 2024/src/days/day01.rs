use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let solution = match part {
        Part::One => 1337,
        Part::Two => 1337,
    };
    Ok(Solution::Num(solution))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    #[test]
    #[ignore]
    fn solve_part_one_example() {
        let input = Cursor::new("");
        assert_eq!(Solution::Num(0), solve(Part::One, input).unwrap());
    }

    #[test]
    #[ignore]
    fn solve_part_one() {
        let input = file_reader("input/day01").unwrap();
        assert_eq!(Solution::Num(0), solve(Part::One, input).unwrap());
    }

    #[test]
    #[ignore]
    fn solve_part_two_example() {
        let input = Cursor::new("");
        assert_eq!(Solution::Num(0), solve(Part::Two, input).unwrap());
    }

    #[test]
    #[ignore]
    fn solve_part_two() {
        let input = file_reader("input/day01").unwrap();
        assert_eq!(Solution::Num(0), solve(Part::Two, input).unwrap());
    }
}
