use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let reports = parse_reports(input);

    let solution = match part {
        Part::One => reports.filter(|report| report.is_safe()).count(),
        Part::Two => reports.filter(|report| report.is_almost_safe()).count(),
    };

    Ok(Solution::Num(solution as i64))
}

fn parse_reports(mut input: impl BufRead) -> impl Iterator<Item = Report> {
    let mut line = String::new();
    std::iter::from_fn(move || {
        line.clear();
        if input.read_line(&mut line).unwrap() == 0 {
            None
        } else {
            Some(Report(
                line.split_whitespace()
                    .map(|level| level.parse().unwrap())
                    .collect(),
            ))
        }
    })
}

struct Report(Vec<i64>);

impl Report {
    pub fn is_safe(&self) -> bool {
        let mut direction = None;
        self.0.windows(2).all(|pair| {
            let diff = pair[1] - pair[0];
            *direction.get_or_insert(diff.signum()) == diff.signum()
                && (1..=3).contains(&diff.abs())
        })
    }

    pub fn is_almost_safe(&self) -> bool {
        self.is_safe() || (0..self.0.len()).any(|index| self.dampen(index).is_safe())
    }

    fn dampen(&self, index: usize) -> Report {
        let mut dampened = self.0.clone();
        dampened.remove(index);
        Report(dampened)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        7 6 4 2 1\n\
        1 2 7 8 9\n\
        9 7 6 2 1\n\
        1 3 2 4 5\n\
        8 6 4 4 1\n\
        1 3 6 7 9\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(2), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day02").unwrap();
        assert_eq!(Solution::Num(663), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(4), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day02").unwrap();
        assert_eq!(Solution::Num(692), solve(Part::Two, input).unwrap());
    }
}
