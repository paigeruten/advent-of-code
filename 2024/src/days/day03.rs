use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let use_conditionals = match part {
        Part::One => false,
        Part::Two => true,
    };

    let solution = parse_muls(input, use_conditionals)?
        .iter()
        .map(|MulInstruction(a, b)| a * b)
        .sum();

    Ok(Solution::Num(solution))
}

struct MulInstruction(i64, i64);

fn parse_muls(
    input: impl BufRead,
    use_conditionals: bool,
) -> color_eyre::Result<Vec<MulInstruction>> {
    enum State {
        Start,

        // mul(A,B)
        M,
        Mu,
        Mul,
        MulOpen,
        MulOpenDigits(String),
        MulOpenIntComma(i64),
        MulOpenIntCommaDigits(i64, String),

        // do()
        D,
        Do,
        DoOpen,

        // don't()
        Don,
        Donu,
        Donut,
        DonutOpen,
    }
    use State::*;

    let mut state = Start;
    let mut muls_enabled = true;
    let mut muls = Vec::new();

    for byte in input.bytes() {
        let ch = char::from(byte.unwrap());
        state = match (state, ch) {
            (M, 'u') => Mu,
            (Mu, 'l') => Mul,
            (Mul, '(') => MulOpen,
            (MulOpen, ch) if ch.is_ascii_digit() => MulOpenDigits(ch.to_string()),
            (MulOpenDigits(digits), ',') => MulOpenIntComma(digits.parse().unwrap()),
            (MulOpenDigits(digits), ch) if ch.is_ascii_digit() => {
                MulOpenDigits(format!("{digits}{ch}"))
            }
            (MulOpenIntComma(left), ch) if ch.is_ascii_digit() => {
                MulOpenIntCommaDigits(left, ch.to_string())
            }
            (MulOpenIntCommaDigits(left, digits), ')') => {
                muls.push(MulInstruction(left, digits.parse().unwrap()));
                Start
            }
            (MulOpenIntCommaDigits(left, digits), ch) if ch.is_ascii_digit() => {
                MulOpenIntCommaDigits(left, format!("{digits}{ch}"))
            }

            (D, 'o') => Do,
            (Do, '(') => DoOpen,
            (DoOpen, ')') => {
                muls_enabled = true;
                Start
            }

            (Do, 'n') => Don,
            (Don, '\'') => Donu,
            (Donu, 't') => Donut,
            (Donut, '(') => DonutOpen,
            (DonutOpen, ')') => {
                muls_enabled = false;
                Start
            }

            (_, 'm') if muls_enabled => M,
            (_, 'd') if use_conditionals => D,
            _ => Start,
        };
    }

    Ok(muls)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    #[test]
    fn solve_part_one_example() {
        let input =
            Cursor::new("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))");
        assert_eq!(Solution::Num(161), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day03").unwrap();
        assert_eq!(Solution::Num(167650499), solve(Part::One, input).unwrap());
    }

    #[test]
    fn handle_adjacent_muls_edge_case() {
        let input = Cursor::new("mulmul(3,4)");
        assert_eq!(Solution::Num(12), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(
            "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
        );
        assert_eq!(Solution::Num(48), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day03").unwrap();
        assert_eq!(Solution::Num(95846796), solve(Part::Two, input).unwrap());
    }
}
