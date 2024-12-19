use std::io::BufRead;

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let mut computer = parser::parse(input)?;

    Ok(match part {
        Part::One => {
            computer.run();
            let output_csv = computer
                .output
                .iter()
                .map(|value| format!("{value}"))
                .collect::<Vec<_>>()
                .join(",");
            Solution::Str(output_csv)
        }
        Part::Two => {
            let mut prefixes = vec![0];
            let mut solutions = Vec::new();
            while let Some(prefix) = prefixes.pop() {
                for tribit in 0b000..=0b111 {
                    let input = (prefix << 3) | tribit;
                    if input == 0 {
                        continue;
                    }

                    let mut cur_computer = computer.clone();
                    cur_computer.reg.a = input;
                    cur_computer.run();

                    if cur_computer.program == cur_computer.output {
                        solutions.push(input);
                    } else if cur_computer.program.ends_with(&cur_computer.output) {
                        prefixes.push(input);
                    }
                }
            }
            Solution::Num(*solutions.iter().min().unwrap())
        }
    })
}

mod parser {
    use std::{io::BufRead, str::FromStr};

    use nom::{
        bytes::complete::tag,
        character::complete::{digit1, line_ending},
        combinator::{map, map_res},
        multi::separated_list1,
        sequence::{delimited, preceded, separated_pair, tuple},
        IResult,
    };

    use super::{Computer, Registers};

    pub fn parse(mut input: impl BufRead) -> color_eyre::Result<Computer> {
        let mut input_str = String::new();
        input.read_to_string(&mut input_str)?;

        let (_, computer) = computer(input_str.as_str()).map_err(|err| err.to_owned())?;

        Ok(computer)
    }

    fn computer(i: &str) -> IResult<&str, Computer> {
        map(
            separated_pair(registers, line_ending, program),
            |(reg, program)| Computer {
                reg,
                program,
                ..Default::default()
            },
        )(i)
    }

    fn registers(i: &str) -> IResult<&str, Registers> {
        map(
            tuple((
                delimited(tag("Register A: "), integer, line_ending),
                delimited(tag("Register B: "), integer, line_ending),
                delimited(tag("Register C: "), integer, line_ending),
            )),
            |(a, b, c)| Registers {
                a,
                b,
                c,
                ..Default::default()
            },
        )(i)
    }

    fn program(i: &str) -> IResult<&str, Vec<u8>> {
        preceded(tag("Program: "), separated_list1(tag(","), integer))(i)
    }

    fn integer<T: FromStr>(i: &str) -> IResult<&str, T> {
        map_res(digit1, |s: &str| s.parse::<T>())(i)
    }
}

#[derive(Debug, Clone, Default)]
struct Computer {
    reg: Registers,
    program: Vec<u8>,
    output: Vec<u8>,
}

impl Computer {
    pub fn run(&mut self) {
        while let Some(&instruction) = self.program.get(self.reg.ip) {
            self.execute_instruction(instruction, self.program[self.reg.ip + 1]);
        }
    }

    fn execute_instruction(&mut self, instruction: u8, operand: u8) {
        match instruction {
            // adv
            0 => self.reg.a >>= self.combo(operand),
            // bxl
            1 => self.reg.b ^= self.literal(operand),
            // bst
            2 => self.reg.b = self.combo(operand) & 0b111,
            // jnz
            3 => {
                if self.reg.a != 0 {
                    self.reg.ip = self.literal(operand) as usize;
                    return; // skip ip increment
                }
            }
            // bxc
            4 => self.reg.b ^= self.reg.c,
            // out
            5 => self.output.push((self.combo(operand) & 0b111) as u8),
            // bdv
            6 => self.reg.b = self.reg.a >> self.combo(operand),
            // cdv
            7 => self.reg.c = self.reg.a >> self.combo(operand),

            _ => panic!("Invalid instruction"),
        }
        self.reg.ip += 2;
    }

    fn literal(&self, operand: u8) -> i64 {
        operand as i64
    }

    fn combo(&self, operand: u8) -> i64 {
        match operand {
            0..=3 => operand as i64,
            4 => self.reg.a,
            5 => self.reg.b,
            6 => self.reg.c,
            _ => panic!("Invalid operand"),
        }
    }
}

#[derive(Debug, Clone, Default)]
struct Registers {
    a: i64,
    b: i64,
    c: i64,
    ip: usize,
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const FIRST_EXAMPLE: &str = "\
        Register A: 729\n\
        Register B: 0\n\
        Register C: 0\n\
        \n\
        Program: 0,1,5,4,3,0\n\
        ";

    const SECOND_EXAMPLE: &str = "\
        Register A: 2024\n\
        Register B: 0\n\
        Register C: 0\n\
        \n\
        Program: 0,3,5,4,3,0\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(FIRST_EXAMPLE);
        assert_eq!(
            Solution::Str("4,6,3,5,6,3,5,2,1,0".into()),
            solve(Part::One, input).unwrap()
        );
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day17").unwrap();
        assert_eq!(
            Solution::Str("4,0,4,7,1,2,7,1,6".into()),
            solve(Part::One, input).unwrap()
        );
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(SECOND_EXAMPLE);
        assert_eq!(Solution::Num(117440), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day17").unwrap();
        assert_eq!(
            Solution::Num(202322348616234),
            solve(Part::Two, input).unwrap()
        );
    }
}
