use std::collections::VecDeque;
use std::convert::TryFrom;
use wasm_bindgen::prelude::*;
use web_sys::console;

use crate::instruction::{Opcode, Instruction, ParameterMode};

#[wasm_bindgen]
#[derive(Debug, Clone)]
pub struct Program {
    code: Vec<i64>,
}

#[wasm_bindgen]
impl Program {
    #[allow(dead_code)]
    pub fn new(code: Vec<i64>) -> Self {
        Program { code }
    }
}

#[wasm_bindgen]
#[derive(Debug, PartialEq, Eq)]
pub enum ExecuteStatus {
    NeedInput,
    Output,
    Halted,
}

#[wasm_bindgen]
#[derive(Debug)]
pub struct VM {
    memory: Vec<i64>,
    ip: usize,
    bp: usize,
    input: VecDeque<i64>,
    output: VecDeque<i64>,
    pub cycles: usize,
    pub debug: bool,
}

#[wasm_bindgen]
impl VM {
    pub fn new(program: &Program) -> Self {
        VM {
            memory: program.code.clone(),
            ip: 0,
            bp: 0,
            input: VecDeque::new(),
            output: VecDeque::new(),
            cycles: 0,
            debug: false,
        }
    }

    pub fn set_memory(&mut self, address: usize, value: i64) {
        self.memory[address] = value;
    }

    pub fn send_input(&mut self, value: i64) {
        self.input.push_back(value);
    }

    pub fn recv_output(&mut self) -> i64 {
        self.output.pop_front().expect("No output to receive")
    }

    pub fn execute(&mut self) -> ExecuteStatus {
        loop {
            let inst = Instruction::try_from(self.memory[self.ip])
                .unwrap_or_else(|_| {
                    panic!("Invalid instruction {} at {}", self.memory[self.ip], self.ip);
                });

            if self.debug {
                console::log_1(&format!("{:<4} | {}",
                    self.ip,
                    inst.disassemble(&self.memory[self.ip .. self.ip + inst.length()])
                ).into());
            }

            self.cycles += 1;

            match inst.opcode() {
                Opcode::Add => {
                    *self.mut_param(&inst, 2) = self.param(&inst, 0) + self.param(&inst, 1);
                }
                Opcode::Mul => {
                    *self.mut_param(&inst, 2) = self.param(&inst, 0) * self.param(&inst, 1);
                }
                Opcode::In => {
                    if let Some(value) = self.input.pop_front() {
                        *self.mut_param(&inst, 0) = value;
                    } else {
                        return ExecuteStatus::NeedInput;
                    }
                }
                Opcode::Out => {
                    let value = self.param(&inst, 0);
                    self.output.push_back(value);
                    self.ip += inst.length();
                    return ExecuteStatus::Output;
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
                Opcode::Base => {
                    self.bp = (self.bp as i64 + self.param(&inst, 0)) as usize;
                }
                Opcode::Halt => return ExecuteStatus::Halted,
            };

            self.ip += inst.length();
        }
    }

    fn param(&mut self, inst: &Instruction, param: usize) -> i64 {
        let address = self.param_address(inst, param);
        self.memory[address]
    }

    fn mut_param(&mut self, inst: &Instruction, param: usize) -> &mut i64 {
        let address = self.param_address(inst, param);
        if inst.param_mode(param) == ParameterMode::Immediate {
            panic!("Can't write to immediate mode param");
        }
        &mut self.memory[address]
    }

    fn param_address(&mut self, inst: &Instruction, param: usize) -> usize {
        use ParameterMode::*;

        let address = match inst.param_mode(param) {
            Position => self.memory[self.ip + param + 1] as usize,
            Relative => (self.bp as i64 + self.memory[self.ip + param + 1]) as usize,
            Immediate => self.ip + param + 1,
        };

        if address >= self.memory.len() {
            self.memory.resize(address + 1, 0);
        }

        address
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_program_memory(code: &[i64], expected: &[i64]) {
        let mut vm = VM::new(&Program::new(code.to_vec()));
        assert_eq!(vm.execute(), ExecuteStatus::Halted);
        assert_eq!(vm.memory, expected);
    }

    fn test_program(code: &[i64], input: &[i64], output: &[i64]) {
        let mut vm = VM::new(&Program::new(code.to_vec()));
        for &value in input {
            vm.send_input(value);
        }
        let mut actual_output = Vec::new();
        loop {
            match vm.execute() {
                ExecuteStatus::Output => actual_output.push(vm.recv_output()),
                ExecuteStatus::NeedInput => panic!("Not enough input"),
                ExecuteStatus::Halted => break,
            }
        }
        assert_eq!(actual_output, output);
    }

    #[test]
    fn pauses_execution_to_wait_for_input() {
        let add = Program::new(vec![
            3,100,
            3,101,
            1,100,101,102,
            4,102,
            99,
        ]);

        let mut vm = VM::new(&add);

        assert_eq!(vm.execute(), ExecuteStatus::NeedInput);
        assert_eq!(vm.ip, 0);
        vm.send_input(5);

        assert_eq!(vm.execute(), ExecuteStatus::NeedInput);
        assert_eq!(vm.ip, 2);
        vm.send_input(8);

        assert_eq!(vm.execute(), ExecuteStatus::Output);
        assert_eq!(vm.recv_output(), 13);
        assert_eq!(vm.ip, 10);

        assert_eq!(vm.execute(), ExecuteStatus::Halted);
        assert_eq!(vm.ip, 10);
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

    #[test]
    fn day9_test_cases() {
        let large_number = &[
            104,1125899906842624,
            99,
        ];
        test_program(large_number, &[], &[1125899906842624]);

        let large_number = &[
            1102,34915192,34915192,7,
            4,7,
            99,
            0,
        ];
        test_program(large_number, &[], &[1219070632396864]);

        let quine = &[
            109,1,
            204,-1,
            1001,100,1,100,
            1008,100,16,101,
            1006,101,0,
            99,
        ];
        test_program(quine, &[], quine);
    }
}
