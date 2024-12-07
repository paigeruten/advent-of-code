use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let equations = parse(input)?;

    let num_ops = match part {
        Part::One => 2,
        Part::Two => 3,
    };

    let solution = equations
        .iter()
        .filter(|equation| equation.is_possible(num_ops))
        .map(|equation| equation.test_value)
        .sum();

    Ok(Solution::Num(solution))
}

fn parse(input: impl BufRead) -> color_eyre::Result<Vec<Equation>> {
    let mut equations = Vec::new();
    for line in input.lines() {
        let line = line?;

        let (left, right) = line.split_once(':').unwrap();
        equations.push(Equation {
            test_value: left.trim().parse().unwrap(),
            numbers: right
                .split_whitespace()
                .map(|n| n.parse().unwrap())
                .collect(),
        });
    }
    Ok(equations)
}

#[derive(Debug)]
struct Equation {
    test_value: i64,
    numbers: Vec<i64>,
}

impl Equation {
    pub fn is_possible(&self, num_ops: u32) -> bool {
        (0..(num_ops.pow(self.numbers.len() as u32 - 1))).any(|mut config| {
            self.numbers.iter().copied().reduce(|acc, n| {
                let op = config % num_ops;
                config /= num_ops;
                match op {
                    0 => acc + n,
                    1 => acc * n,
                    2 => acc * 10_i64.pow(n.ilog10() + 1) + n,
                    _ => unreachable!(),
                }
            }) == Some(self.test_value)
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        190: 10 19\n\
        3267: 81 40 27\n\
        83: 17 5\n\
        156: 15 6\n\
        7290: 6 8 6 15\n\
        161011: 16 10 13\n\
        192: 17 8 14\n\
        21037: 9 7 18 13\n\
        292: 11 6 16 20\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(3749), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day07").unwrap();
        assert_eq!(
            Solution::Num(1153997401072),
            solve(Part::One, input).unwrap()
        );
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(11387), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day07").unwrap();
        assert_eq!(
            Solution::Num(97902809384118),
            solve(Part::Two, input).unwrap()
        );
    }
}
