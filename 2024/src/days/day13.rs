use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let claw_machines = parser::parse(input)?;

    let solution = match part {
        Part::One => claw_machines
            .iter()
            .filter_map(|claw_machine| claw_machine.minimum_required_tokens(Some(100)))
            .sum(),
        Part::Two => claw_machines
            .iter()
            .map(|claw_machine| claw_machine.move_prize(10_000_000_000_000))
            .filter_map(|claw_machine| claw_machine.minimum_required_tokens(None))
            .sum(),
    };

    Ok(Solution::Num(solution))
}

mod parser {
    use nom::{
        branch::alt,
        bytes::complete::tag,
        character::complete::{digit1, line_ending},
        combinator::{map, map_res},
        multi::separated_list1,
        sequence::{delimited, separated_pair, tuple},
        IResult, Parser,
    };
    use std::io::BufRead;

    use super::{ClawMachine, Vec2};

    pub fn parse(mut input: impl BufRead) -> color_eyre::Result<Vec<ClawMachine>> {
        let mut input_str = String::new();
        input.read_to_string(&mut input_str)?;

        let (_, claw_machines) = separated_list1(line_ending, claw_machine)
            .parse(input_str.as_str())
            .map_err(|err| err.to_owned())?;

        Ok(claw_machines)
    }

    fn claw_machine(i: &str) -> IResult<&str, ClawMachine> {
        map(
            tuple((button, button, prize)),
            |(button_a, button_b, prize)| ClawMachine {
                button_a,
                button_b,
                prize,
            },
        )(i)
    }

    fn button(i: &str) -> IResult<&str, Vec2> {
        map(
            delimited(
                tuple((tag("Button "), alt((tag("A"), tag("B"))), tag(": X+"))),
                separated_pair(integer, tag(", Y+"), integer),
                line_ending,
            ),
            |(x, y)| Vec2 { x, y },
        )(i)
    }

    fn prize(i: &str) -> IResult<&str, Vec2> {
        map(
            delimited(
                tag("Prize: X="),
                separated_pair(integer, tag(", Y="), integer),
                line_ending,
            ),
            |(x, y)| Vec2 { x, y },
        )(i)
    }

    fn integer(i: &str) -> IResult<&str, i64> {
        map_res(digit1, |s: &str| s.parse::<i64>())(i)
    }
}

#[derive(Debug)]
struct ClawMachine {
    button_a: Vec2,
    button_b: Vec2,
    prize: Vec2,
}

impl ClawMachine {
    pub fn minimum_required_tokens(&self, max_button_presses: Option<i64>) -> Option<i64> {
        let a_x = self.button_a.x as f64;
        let a_y = self.button_a.y as f64;
        let b_x = self.button_b.x as f64;
        let b_y = self.button_b.y as f64;
        let prize_x = self.prize.x as f64;
        let prize_y = self.prize.y as f64;

        let b_presses = (prize_y - a_y * prize_x / a_x) / (b_y - a_y * b_x / a_x);
        let a_presses = (prize_x - b_presses * b_x) / a_x;

        if let Some(max_button_presses) = max_button_presses {
            if a_presses > max_button_presses as f64 || b_presses > max_button_presses as f64 {
                return None;
            }
        }

        if a_presses < 0. || b_presses < 0. {
            return None;
        }

        let (a_presses_rounded, b_presses_rounded) = (a_presses.round(), b_presses.round());

        if (a_presses - a_presses_rounded).abs() > 0.001
            || (b_presses - b_presses_rounded).abs() > 0.001
        {
            return None;
        }

        Some(3 * a_presses_rounded as i64 + b_presses_rounded as i64)
    }

    pub fn move_prize(&self, delta: i64) -> Self {
        Self {
            prize: Vec2 {
                x: self.prize.x + delta,
                y: self.prize.y + delta,
            },
            ..*self
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
struct Vec2 {
    x: i64,
    y: i64,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        Button A: X+94, Y+34\n\
        Button B: X+22, Y+67\n\
        Prize: X=8400, Y=5400\n\
        \n\
        Button A: X+26, Y+66\n\
        Button B: X+67, Y+21\n\
        Prize: X=12748, Y=12176\n\
        \n\
        Button A: X+17, Y+86\n\
        Button B: X+84, Y+37\n\
        Prize: X=7870, Y=6450\n\
        \n\
        Button A: X+69, Y+23\n\
        Button B: X+27, Y+71\n\
        Prize: X=18641, Y=10279\n\
    ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(480), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day13").unwrap();
        assert_eq!(Solution::Num(28138), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day13").unwrap();
        assert_eq!(
            Solution::Num(108394825772874),
            solve(Part::Two, input).unwrap()
        );
    }
}
