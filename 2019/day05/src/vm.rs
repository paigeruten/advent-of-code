use std::convert::TryFrom;
use std::num::ParseIntError;
use std::str::FromStr;

use crate::instruction::{Opcode, Instruction, ParameterMode};

#[derive(Debug)]
pub struct Program {
    code: Vec<i32>,
}

impl Program {
    #[allow(dead_code)]
    pub fn new(code: Vec<i32>) -> Self {
        Program { code }
    }

    pub fn code(&self) -> &Vec<i32> {
        &self.code
    }
}

impl FromStr for Program {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let code: Vec<i32> = s
            .trim_end()
            .split(',')
            .map(str::parse)
            .collect::<Result<_, _>>()?;

        Ok(Program { code })
    }
}

#[derive(Debug)]
pub struct VM {
    memory: Vec<i32>,
    ip: usize,
    input: Vec<i32>,
    output: Vec<i32>,
    debug: bool,
}

impl VM {
    pub fn new(program: &Program) -> Self {
        VM {
            memory: program.code().clone(),
            ip: 0,
            input: Vec::new(),
            output: Vec::new(),
            debug: false,
        }
    }

    pub fn write_input(&mut self, values: &[i32]) {
        self.input.extend_from_slice(values);
    }

    pub fn output(&self) -> &[i32] {
        &self.output
    }

    pub fn debug(&mut self, yes: bool) {
        self.debug = yes;
    }

    #[cfg(test)]
    pub fn memory(&self) -> &[i32] {
        &self.memory
    }

    pub fn execute(&mut self) {
        loop {
            let inst = Instruction::try_from(self.memory[self.ip])
                .unwrap_or_else(|_| panic!("Invalid instruction {}", self.memory[self.ip]));

            if self.debug {
                print!("{:<4} | ", self.ip);
                inst.disassemble(&self.memory[self.ip .. self.ip + inst.length()]);
            }

            match inst.opcode() {
                Opcode::Add => {
                    *self.mut_param(&inst, 2) = self.param(&inst, 0) + self.param(&inst, 1);
                }
                Opcode::Mul => {
                    *self.mut_param(&inst, 2) = self.param(&inst, 0) * self.param(&inst, 1);
                }
                Opcode::In => {
                    if self.input.is_empty() {
                        panic!("No input to read");
                    }
                    *self.mut_param(&inst, 0) = self.input.remove(0);
                }
                Opcode::Out => {
                    self.output.push(self.param(&inst, 0));
                }
                Opcode::JmpT => {
                    if self.param(&inst, 0) != 0 {
                        self.ip = self.param(&inst, 1) as usize;
                        continue;
                    }
                }
                Opcode::JmpF => {
                    if self.param(&inst, 0) == 0 {
                        self.ip = self.param(&inst, 1) as usize;
                        continue;
                    }
                }
                Opcode::Lt => {
                    *self.mut_param(&inst, 2) =
                        if self.param(&inst, 0) < self.param(&inst, 1) {
                            1
                        } else {
                            0
                        };
                }
                Opcode::Eql => {
                    *self.mut_param(&inst, 2) =
                        if self.param(&inst, 0) == self.param(&inst, 1) {
                            1
                        } else {
                            0
                        };
                }
                Opcode::Halt => break,
            };

            self.ip += inst.length();
        }
    }

    fn param(&self, inst: &Instruction, param: usize) -> i32 {
        use ParameterMode::*;

        match inst.param_mode(param) {
            Position => {
                let position = self.memory[self.ip + param + 1] as usize;
                self.memory[position]
            }
            Immediate => self.memory[self.ip + param + 1],
        }
    }

    fn mut_param(&mut self, inst: &Instruction, param: usize) -> &mut i32 {
        use ParameterMode::*;

        match inst.param_mode(param) {
            Position => {
                let position = self.memory[self.ip + param + 1] as usize;
                &mut self.memory[position]
            }
            Immediate => panic!("Can't write to immediate mode param"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_program_memory(code: &[i32], expected: &[i32]) {
        let mut vm = VM::new(&Program::new(code.to_vec()));
        vm.execute();
        assert_eq!(vm.memory(), expected);
    }

    fn test_program(code: &[i32], input: &[i32], output: &[i32]) {
        let mut vm = VM::new(&Program::new(code.to_vec()));
        vm.write_input(input);
        vm.execute();
        assert_eq!(vm.output(), output);
    }

    #[test]
    fn day2_test_cases() {
        test_program_memory(
            &[1,0,0,0,99],
            &[2,0,0,0,99],
        );

        test_program_memory(
            &[2,3,0,3,99],
            &[2,3,0,6,99],
        );

        test_program_memory(
            &[2,4,4,5,99,0],
            &[2,4,4,5,99,9801],
        );

        test_program_memory(
            &[1,1,1,4,99,5,6,0,99],
            &[30,1,1,4,2,5,6,0,99],
        );
    }

    #[test]
    fn day5_test_cases() {
        let echo = &[
            3,0,
            4,0,
            99,
        ];
        test_program(echo, &[42], &[42]);
        test_program(echo, &[123], &[123]);

        let equal_to_8 = &[
            3,9,
            8,9,10,9,
            4,9,
            99,
            -1,8,
        ];
        test_program(equal_to_8, &[8], &[1]);
        test_program(equal_to_8, &[7], &[0]);
        test_program(equal_to_8, &[9], &[0]);

        let less_than_8 = &[
            3,9,
            7,9,10,9,
            4,9,
            99,
            -1,8,
        ];
        test_program(less_than_8, &[7], &[1]);
        test_program(less_than_8, &[8], &[0]);
        test_program(less_than_8, &[9], &[0]);

        let equal_to_8_imm = &[
            3,3,
            1108,-1,8,3,
            4,3,
            99,
        ];
        test_program(equal_to_8_imm, &[8], &[1]);
        test_program(equal_to_8_imm, &[7], &[0]);
        test_program(equal_to_8_imm, &[9], &[0]);

        let less_than_8_imm = &[
            3,3,
            1107,-1,8,3,
            4,3,
            99,
        ];
        test_program(less_than_8_imm, &[7], &[1]);
        test_program(less_than_8_imm, &[8], &[0]);
        test_program(less_than_8_imm, &[9], &[0]);

        let is_nonzero = &[
            3,12,
            6,12,15,
            1,13,14,13,
            4,13,
            99,
            -1,0,1,9,
        ];
        test_program(is_nonzero, &[0], &[0]);
        test_program(is_nonzero, &[8], &[1]);

        let is_nonzero_imm = &[
            3,3,
            1105,-1,9,
            1101,0,0,12,
            4,12,
            99,
            1,
        ];
        test_program(is_nonzero_imm, &[0], &[0]);
        test_program(is_nonzero_imm, &[8], &[1]);

        let spaceship_8 = &[
            3,21,
            1008,21,8,20,
            1005,20,22,
            107,8,21,20,
            1006,20,31,
            1106,0,36,
            98,0,0,
            1002,21,125,20,
            4,20,
            1105,1,46,
            104,999,
            1105,1,46,
            1101,1000,1,20,
            4,20,
            1105,1,46,
            98,
            99,
        ];
        test_program(spaceship_8, &[10], &[1001]);
        test_program(spaceship_8, &[9], &[1001]);
        test_program(spaceship_8, &[8], &[1000]);
        test_program(spaceship_8, &[7], &[999]);
        test_program(spaceship_8, &[6], &[999]);
    }
}
