use lazy_static::lazy_static;
use regex::Regex;
use std::error::Error;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;

#[derive(Clone, Copy, Debug, PartialEq)]
enum Op {
  Addr,
  Addi,
  Mulr,
  Muli,
  Banr,
  Bani,
  Borr,
  Bori,
  Setr,
  Seti,
  Gtir,
  Gtri,
  Gtrr,
  Eqir,
  Eqri,
  Eqrr,
}

use self::Op::*;

impl FromStr for Op {
  type Err = ();

  fn from_str(string: &str) -> Result<Op, Self::Err> {
    Ok(match string {
      "addr" => Addr,
      "addi" => Addi,
      "mulr" => Mulr,
      "muli" => Muli,
      "banr" => Banr,
      "bani" => Bani,
      "borr" => Borr,
      "bori" => Bori,
      "setr" => Setr,
      "seti" => Seti,
      "gtir" => Gtir,
      "gtri" => Gtri,
      "gtrr" => Gtrr,
      "eqir" => Eqir,
      "eqri" => Eqri,
      "eqrr" => Eqrr,
      _ => return Err(()),
    })
  }
}

#[derive(Debug, PartialEq, Clone, Copy, Default)]
struct State(i32, i32, i32, i32, i32, i32);

impl State {
  pub fn reg(self, index: i32) -> i32 {
    match index {
      0 => self.0,
      1 => self.1,
      2 => self.2,
      3 => self.3,
      4 => self.4,
      5 => self.5,
      _ => unreachable!(),
    }
  }

  pub fn set_reg(self, index: i32, value: i32) -> State {
    let mut state = self;

    match index {
      0 => state.0 = value,
      1 => state.1 = value,
      2 => state.2 = value,
      3 => state.3 = value,
      4 => state.4 = value,
      5 => state.5 = value,
      _ => unreachable!(),
    }

    state
  }

  pub fn exec(self, op: Op, a: i32, b: i32, c: i32) -> State {
    match op {
      Addr => self.addr(a, b, c),
      Addi => self.addi(a, b, c),
      Mulr => self.mulr(a, b, c),
      Muli => self.muli(a, b, c),
      Banr => self.banr(a, b, c),
      Bani => self.bani(a, b, c),
      Borr => self.borr(a, b, c),
      Bori => self.bori(a, b, c),
      Setr => self.setr(a, b, c),
      Seti => self.seti(a, b, c),
      Gtir => self.gtir(a, b, c),
      Gtri => self.gtri(a, b, c),
      Gtrr => self.gtrr(a, b, c),
      Eqir => self.eqir(a, b, c),
      Eqri => self.eqri(a, b, c),
      Eqrr => self.eqrr(a, b, c),
    }
  }

  pub fn addr(self, reg_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) + self.reg(reg_b);
    self.set_reg(reg_out, result)
  }

  pub fn addi(self, reg_a: i32, val_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) + val_b;
    self.set_reg(reg_out, result)
  }

  pub fn mulr(self, reg_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) * self.reg(reg_b);
    self.set_reg(reg_out, result)
  }

  pub fn muli(self, reg_a: i32, val_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) * val_b;
    self.set_reg(reg_out, result)
  }

  pub fn banr(self, reg_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) & self.reg(reg_b);
    self.set_reg(reg_out, result)
  }

  pub fn bani(self, reg_a: i32, val_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) & val_b;
    self.set_reg(reg_out, result)
  }

  pub fn borr(self, reg_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) | self.reg(reg_b);
    self.set_reg(reg_out, result)
  }

  pub fn bori(self, reg_a: i32, val_b: i32, reg_out: i32) -> State {
    let result = self.reg(reg_a) | val_b;
    self.set_reg(reg_out, result)
  }

  pub fn setr(self, reg_a: i32, _b: i32, reg_out: i32) -> State {
    self.set_reg(reg_out, self.reg(reg_a))
  }

  pub fn seti(self, val_a: i32, _b: i32, reg_out: i32) -> State {
    self.set_reg(reg_out, val_a)
  }

  pub fn gtir(self, val_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = if val_a > self.reg(reg_b) { 1 } else { 0 };
    self.set_reg(reg_out, result)
  }

  pub fn gtri(self, reg_a: i32, val_b: i32, reg_out: i32) -> State {
    let result = if self.reg(reg_a) > val_b { 1 } else { 0 };
    self.set_reg(reg_out, result)
  }

  pub fn gtrr(self, reg_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = if self.reg(reg_a) > self.reg(reg_b) { 1 } else { 0 };
    self.set_reg(reg_out, result)
  }

  pub fn eqir(self, val_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = if val_a == self.reg(reg_b) { 1 } else { 0 };
    self.set_reg(reg_out, result)
  }

  pub fn eqri(self, reg_a: i32, val_b: i32, reg_out: i32) -> State {
    let result = if self.reg(reg_a) == val_b { 1 } else { 0 };
    self.set_reg(reg_out, result)
  }

  pub fn eqrr(self, reg_a: i32, reg_b: i32, reg_out: i32) -> State {
    let result = if self.reg(reg_a) == self.reg(reg_b) { 1 } else { 0 };
    self.set_reg(reg_out, result)
  }
}

#[derive(Debug, PartialEq, Clone, Copy)]
struct Instruction {
  op: Op,
  a: i32,
  b: i32,
  c: i32,
}

impl Instruction {
  pub fn op(self) -> Op {
    self.op
  }

  pub fn a(self) -> i32 {
    self.a
  }

  pub fn b(self) -> i32 {
    self.b
  }

  pub fn c(self) -> i32 {
    self.c
  }
}

impl FromStr for Instruction {
  type Err = Box<dyn Error>;

  fn from_str(string: &str) -> Result<Instruction, Self::Err> {
    lazy_static! {
      static ref STATE_REGEX: Regex =
        Regex::new(r"^(\w+) (\d+) (\d+) (\d+)$").unwrap();
    }

    let caps = STATE_REGEX.captures(string)
      .ok_or("Invalid instruction string")?;

    Ok(Instruction {
      op: caps.get(1).unwrap().as_str().parse().unwrap(),
      a: caps.get(2).unwrap().as_str().parse()?,
      b: caps.get(3).unwrap().as_str().parse()?,
      c: caps.get(4).unwrap().as_str().parse()?,
    })
  }
}

#[derive(Debug, PartialEq)]
struct Program {
  ip_reg: i32,
  instructions: Vec<Instruction>,
  ip: i32,
  state: State,
}

impl Program {
  pub fn ip(&self) -> i32 {
    self.ip
  }

  pub fn state(&self) -> State {
    self.state
  }

  pub fn set_state(&mut self, state: State) {
    self.state = state;
  }

  pub fn exec(&mut self) {
    loop {
      if !self.step() { break; }
    }
  }

  pub fn step(&mut self) -> bool {
    let inst = self.instructions[self.ip as usize];

    self.state = self.state.exec(inst.op(), inst.a(), inst.b(), inst.c());
    self.ip = self.state.reg(self.ip_reg);
    self.ip += 1;
    self.state = self.state.set_reg(self.ip_reg, self.ip);

    self.ip >= 0 && self.ip < self.instructions.len() as i32
  }
}

impl FromStr for Program {
  type Err = Box<dyn Error>;

  fn from_str(string: &str) -> Result<Program, Self::Err> {
    lazy_static! {
      static ref IP_REGEX: Regex = Regex::new(r"^#ip (\d+)$").unwrap();
    }

    let mut lines = string.lines();

    let caps = IP_REGEX.captures(lines.next().expect("Program is blank"))
      .ok_or("Missing #ip directive")?;
    let ip_reg: i32 = caps.get(1).unwrap().as_str().parse()?;

    let instructions: Vec<Instruction> = lines
      .map(|line| line.parse())
      .collect::<Result<_, _>>()?;

    Ok(Program { ip_reg, instructions, ip: 0, state: Default::default() })
  }
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);
  let mut input = String::new();

  reader.read_to_string(&mut input).unwrap();

  let mut program: Program = input.trim().parse().unwrap();
  //program.set_state(program.state().set_reg(0, 1));

  program.exec();

  println!("Register 0: {}", program.state().reg(0));
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_exec() {
    let state = State(2, 3, 6, 7, 11, 12);

    assert_eq!(state.exec(Op::Addi, 2, 4, 3), State(2, 3, 6, 10, 11, 12));
  }

  #[test]
  fn test_instruction_parse() {
    assert_eq!(
      "addi 26 1 0".parse::<Instruction>().unwrap(),
      Instruction { op: Addi, a: 26, b: 1, c: 0 }
    );
  }

  #[test]
  fn test_program_parse() {
    let program_str = "
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
";

    let program: Program = program_str.trim().parse().unwrap();

    assert_eq!(
      program,
      Program {
        ip_reg: 0,
        instructions: vec![
          Instruction { op: Seti, a: 5, b: 0, c: 1 },
          Instruction { op: Seti, a: 6, b: 0, c: 2 },
          Instruction { op: Addi, a: 0, b: 1, c: 0 },
          Instruction { op: Addr, a: 1, b: 2, c: 3 },
          Instruction { op: Setr, a: 1, b: 0, c: 0 },
          Instruction { op: Seti, a: 8, b: 0, c: 4 },
          Instruction { op: Seti, a: 9, b: 0, c: 5 },
        ],
        ip: 0,
        state: State(0, 0, 0, 0, 0, 0),
      }
    );
  }

  #[test]
  fn test_program_step() {
    let mut program: Program = "
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
    ".trim().parse().unwrap();

    assert_eq!(program.ip(), 0);
    assert_eq!(program.state(), State(0, 0, 0, 0, 0, 0));

    assert!(program.step());
    assert_eq!(program.ip(), 1);
    assert_eq!(program.state(), State(1, 5, 0, 0, 0, 0));

    assert!(program.step());
    assert_eq!(program.ip(), 2);
    assert_eq!(program.state(), State(2, 5, 6, 0, 0, 0));

    assert!(program.step());
    assert_eq!(program.ip(), 4);
    assert_eq!(program.state(), State(4, 5, 6, 0, 0, 0));

    assert!(program.step());
    assert_eq!(program.ip(), 6);
    assert_eq!(program.state(), State(6, 5, 6, 0, 0, 0));

    assert_eq!(program.step(), false);
    assert_eq!(program.ip(), 7);
    assert_eq!(program.state(), State(7, 5, 6, 0, 0, 9));
  }

  #[test]
  fn test_program_exec() {
    let mut program: Program = "
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
    ".trim().parse().unwrap();

    program.exec();
    assert_eq!(program.ip(), 7);
    assert_eq!(program.state(), State(7, 5, 6, 0, 0, 9));
  }
}

