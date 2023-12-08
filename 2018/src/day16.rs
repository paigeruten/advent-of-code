use lazy_static::lazy_static;
use regex::Regex;
use std::collections::HashMap;
use std::collections::HashSet;
use std::fs::File;
use std::error::Error;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;

#[derive(Clone, Copy, Debug, PartialEq, Hash, Eq)]
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

const OPS: [Op; 16] = [
  Addr, Addi, Mulr, Muli, Banr, Bani, Borr, Bori,
  Setr, Seti, Gtir, Gtri, Gtrr, Eqir, Eqri, Eqrr,
];

#[derive(Debug, PartialEq, Clone, Copy)]
struct State(i32, i32, i32, i32);

impl State {
  pub fn reg(self, index: i32) -> i32 {
    match index {
      0 => self.0,
      1 => self.1,
      2 => self.2,
      3 => self.3,
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

impl FromStr for State {
  type Err = Box<dyn Error>;

  fn from_str(string: &str) -> Result<State, Self::Err> {
    lazy_static! {
      static ref STATE_REGEX: Regex =
        Regex::new(r"^(Before|After): *\[(\d+), (\d+), (\d+), (\d+)\]$").unwrap();
    }

    let caps = STATE_REGEX.captures(string)
      .ok_or("Invalid state string")?;

    Ok(State(
      caps.get(2).unwrap().as_str().parse()?,
      caps.get(3).unwrap().as_str().parse()?,
      caps.get(4).unwrap().as_str().parse()?,
      caps.get(5).unwrap().as_str().parse()?,
    ))
  }
}

#[derive(Debug, PartialEq, Clone, Copy)]
struct Instruction {
  opcode: i32,
  a: i32,
  b: i32,
  c: i32,
}

impl Instruction {
  pub fn opcode(self) -> i32 {
    self.opcode
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

  pub fn possible_ops(self, before: State, after: State) -> Vec<Op> {
    let Instruction { a, b, c, .. } = self;

    OPS.iter()
      .filter(|&&op| before.exec(op, a, b, c) == after)
      .cloned()
      .collect()
  }
}

impl FromStr for Instruction {
  type Err = Box<dyn Error>;

  fn from_str(string: &str) -> Result<Instruction, Self::Err> {
    lazy_static! {
      static ref STATE_REGEX: Regex =
        Regex::new(r"^(\d+) (\d+) (\d+) (\d+)$").unwrap();
    }

    let caps = STATE_REGEX.captures(string)
      .ok_or("Invalid instruction string")?;

    Ok(Instruction {
      opcode: caps.get(1).unwrap().as_str().parse()?,
      a: caps.get(2).unwrap().as_str().parse()?,
      b: caps.get(3).unwrap().as_str().parse()?,
      c: caps.get(4).unwrap().as_str().parse()?,
    })
  }
}

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);
  let mut lines = reader.lines();

  let mut num_samples_behaving_like_three_or_more_opcodes = 0;

  let mut ops_set: HashSet<Op> = HashSet::with_capacity(16);
  for &op in &OPS {
    ops_set.insert(op);
  }

  let mut possible_ops_for_opcode: HashMap<i32, HashSet<Op>> = HashMap::new();
  for opcode in 0..=15 {
    possible_ops_for_opcode.insert(opcode, ops_set.clone());
  }

  let mut last_was_empty = false;
  loop {
    if let Some(Ok(line)) = lines.next() {
      if line.is_empty() {
        if last_was_empty {
          break;
        }
        last_was_empty = true;
        continue;
      } else {
        last_was_empty = false;
      }

      if let Ok(before_state) = line.parse::<State>() {
        let instruction = lines.next().unwrap().unwrap().parse::<Instruction>().unwrap();
        let after_state = lines.next().unwrap().unwrap().parse::<State>().unwrap();

        let possible_ops = instruction.possible_ops(before_state, after_state);

        for &op in &OPS {
          if possible_ops.iter().find(|&&possible_op| possible_op == op).is_none() {
            possible_ops_for_opcode.get_mut(&instruction.opcode()).unwrap().remove(&op);
          }
        }

        if possible_ops.len() >= 3 {
          num_samples_behaving_like_three_or_more_opcodes += 1;
        }
      } else {
        break;
      }
    } else {
      break;
    }
  }

  let mut op_for_opcode: HashMap<i32, Op> = HashMap::with_capacity(16);
  while op_for_opcode.len() < 16 {
    for opcode in 0..=15 {
      if possible_ops_for_opcode[&opcode].len() == 1 {
        let &op = possible_ops_for_opcode[&opcode].iter().next().unwrap();
        for opcode2 in 0..=15 {
          if opcode != opcode2 {
            possible_ops_for_opcode.get_mut(&opcode2).unwrap().remove(&op);
          }
        }
        op_for_opcode.insert(opcode, op);
      }
    }
  }

  let mut state = State(0, 0, 0, 0);
  while let Some(Ok(line)) = lines.next() {
    if line.is_empty() { continue }

    if let Ok(instruction) = line.parse::<Instruction>() {
      let op = op_for_opcode[&instruction.opcode()];
      state = state.exec(op, instruction.a(), instruction.b(), instruction.c());
    }
  }

  println!("Number of samples behaving like 3 or more opcodes: {}", num_samples_behaving_like_three_or_more_opcodes);
  println!("Final state after running the program: {:?}", state);
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_reg() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.reg(0), 2);
    assert_eq!(state.reg(1), 3);
    assert_eq!(state.reg(2), 6);
    assert_eq!(state.reg(3), 7);
  }

  #[test]
  fn test_set_reg() {
    let state = State(0, 0, 0, 0);

    assert_eq!(state.set_reg(0, 42), State(42, 0, 0, 0));
    assert_eq!(state.set_reg(1, 42), State(0, 42, 0, 0));
    assert_eq!(state.set_reg(2, 42), State(0, 0, 42, 0));
    assert_eq!(state.set_reg(3, 42), State(0, 0, 0, 42));
  }

  #[test]
  fn test_addr() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.addr(2, 3, 1), State(2, 13, 6, 7));
    assert_eq!(state.addr(1, 1, 1), State(2, 6, 6, 7));
    assert_eq!(state.addr(0, 2, 2), State(2, 3, 8, 7));
  }

  #[test]
  fn test_addi() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.addi(2, 3, 1), State(2, 9, 6, 7));
    assert_eq!(state.addi(1, 1, 1), State(2, 4, 6, 7));
    assert_eq!(state.addi(3, 0, 0), State(7, 3, 6, 7));
  }

  #[test]
  fn test_mulr() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.mulr(2, 3, 1), State(2, 42, 6, 7));
    assert_eq!(state.mulr(1, 1, 1), State(2, 9, 6, 7));
    assert_eq!(state.mulr(0, 2, 2), State(2, 3, 12, 7));
  }

  #[test]
  fn test_muli() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.muli(2, 3, 1), State(2, 18, 6, 7));
    assert_eq!(state.muli(1, 1, 1), State(2, 3, 6, 7));
    assert_eq!(state.muli(3, 0, 0), State(0, 3, 6, 7));
  }

  #[test]
  fn test_banr() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.banr(2, 3, 1), State(2, 6, 6, 7));
    assert_eq!(state.banr(1, 1, 1), State(2, 3, 6, 7));
    assert_eq!(state.banr(0, 2, 2), State(2, 3, 2, 7));
  }

  #[test]
  fn test_bani() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.bani(2, 3, 1), State(2, 2, 6, 7));
    assert_eq!(state.bani(1, 1, 1), State(2, 1, 6, 7));
    assert_eq!(state.bani(3, 0, 0), State(0, 3, 6, 7));
  }

  #[test]
  fn test_borr() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.borr(2, 3, 1), State(2, 7, 6, 7));
    assert_eq!(state.borr(1, 1, 1), State(2, 3, 6, 7));
    assert_eq!(state.borr(0, 2, 2), State(2, 3, 6, 7));
  }

  #[test]
  fn test_bori() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.bori(2, 3, 1), State(2, 7, 6, 7));
    assert_eq!(state.bori(1, 1, 1), State(2, 3, 6, 7));
    assert_eq!(state.bori(3, 0, 0), State(7, 3, 6, 7));
  }

  #[test]
  fn test_setr() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.setr(2, 0, 1), State(2, 6, 6, 7));
    assert_eq!(state.setr(1, 0, 1), State(2, 3, 6, 7));
    assert_eq!(state.setr(3, 0, 0), State(7, 3, 6, 7));
  }

  #[test]
  fn test_seti() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.seti(0, 0, 0), State(0, 3, 6, 7));
    assert_eq!(state.seti(5, 0, 1), State(2, 5, 6, 7));
    assert_eq!(state.seti(8, 0, 2), State(2, 3, 8, 7));
    assert_eq!(state.seti(9, 0, 3), State(2, 3, 6, 9));
  }

  #[test]
  fn test_gtir() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.gtir(5, 2, 0), State(0, 3, 6, 7));
    assert_eq!(state.gtir(4, 1, 0), State(1, 3, 6, 7));
    assert_eq!(state.gtir(7, 3, 3), State(2, 3, 6, 0));
  }

  #[test]
  fn test_gtri() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.gtri(2, 5, 0), State(1, 3, 6, 7));
    assert_eq!(state.gtri(1, 4, 0), State(0, 3, 6, 7));
    assert_eq!(state.gtri(3, 7, 3), State(2, 3, 6, 0));
  }

  #[test]
  fn test_gtrr() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.gtrr(1, 2, 0), State(0, 3, 6, 7));
    assert_eq!(state.gtrr(2, 1, 0), State(1, 3, 6, 7));
    assert_eq!(state.gtrr(3, 3, 3), State(2, 3, 6, 0));
  }

  #[test]
  fn test_eqir() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.eqir(5, 2, 0), State(0, 3, 6, 7));
    assert_eq!(state.eqir(3, 1, 0), State(1, 3, 6, 7));
    assert_eq!(state.eqir(7, 3, 3), State(2, 3, 6, 1));
  }

  #[test]
  fn test_eqri() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.eqri(2, 5, 0), State(0, 3, 6, 7));
    assert_eq!(state.eqri(1, 3, 0), State(1, 3, 6, 7));
    assert_eq!(state.eqri(3, 7, 3), State(2, 3, 6, 1));
  }

  #[test]
  fn test_eqrr() {
    let state = State(7, 3, 6, 7);

    assert_eq!(state.eqrr(1, 2, 0), State(0, 3, 6, 7));
    assert_eq!(state.eqrr(0, 3, 0), State(1, 3, 6, 7));
    assert_eq!(state.eqrr(3, 3, 3), State(7, 3, 6, 1));
  }

  #[test]
  fn test_exec() {
    let state = State(2, 3, 6, 7);

    assert_eq!(state.exec(Op::Addi, 2, 4, 3), State(2, 3, 6, 10));
  }

  #[test]
  fn test_state_parse() {
    assert_eq!(
      "Before: [2, 3, 6, 78]".parse::<State>().unwrap(),
      State(2, 3, 6, 78)
    );
    assert_eq!(
      "After:  [0, 32, 68, 1]".parse::<State>().unwrap(),
      State(0, 32, 68, 1)
    );
  }

  #[test]
  fn test_instruction_parse() {
    assert_eq!(
      "14 26 1 0".parse::<Instruction>().unwrap(),
      Instruction { opcode: 14, a: 26, b: 1, c: 0 }
    );
  }

  #[test]
  fn test_possible_ops() {
    let instruction = Instruction { opcode: 9, a: 2, b: 1, c: 2 };
    let before = State(3, 2, 1, 1);
    let after = State(3, 2, 2, 1);

    let possible_ops = instruction.possible_ops(before, after);

    assert_eq!(possible_ops.len(), 3);
    assert!(possible_ops.iter().find(|&&op| op == Mulr).is_some());
    assert!(possible_ops.iter().find(|&&op| op == Addi).is_some());
    assert!(possible_ops.iter().find(|&&op| op == Seti).is_some());
  }
}

