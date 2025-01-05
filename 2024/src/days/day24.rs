use std::{collections::HashMap, fmt::Debug, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let mut system = System::parse(input)?;

    let solution = match part {
        Part::One => system.eval_z(),
        Part::Two => {
            let _inspect = system.inspect_z();
            //dbg!(_inspect);
            1337
        }
    };

    Ok(Solution::Num(solution))
}

#[derive(Debug)]
struct System {
    wires: HashMap<Wire, Expr>,
}

impl System {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut wires = HashMap::new();
        for line in input.lines() {
            let line = line?;
            let line = line.trim();
            if let Some((wire, value)) = line.split_once(": ") {
                wires.insert(
                    wire.try_into().unwrap(),
                    Expr::Value(value.parse().unwrap()),
                );
            } else if let Some((expr, out)) = line.split_once(" -> ") {
                let out = out.try_into().unwrap();
                for (op, split_by) in [(Op::And, " AND "), (Op::Or, " OR "), (Op::Xor, " XOR ")] {
                    if let Some((lhs, rhs)) = expr.split_once(split_by) {
                        wires.insert(
                            out,
                            Expr::Gate(op, lhs.try_into().unwrap(), rhs.try_into().unwrap()),
                        );
                    }
                }
            }
        }
        Ok(Self { wires })
    }

    pub fn inspect_z(&self) -> Vec<usize> {
        let mut z = Vec::new();
        for i in 0..=99 {
            let z_wire = Wire([b'z', b'0' + (i / 10), b'0' + (i % 10)]);
            if !self.wires.contains_key(&z_wire) {
                break;
            }

            //println!("{:?} = {}", z_wire, self.inspect(z_wire));
            z.push(self.inspect(z_wire).len());
        }
        z
    }

    pub fn inspect(&self, wire: Wire) -> String {
        match *self.wires.get(&wire).unwrap() {
            Expr::Value(_) => format!("{wire:?}"),
            Expr::Gate(op, lhs, rhs) => {
                format!("({} {op:?} {})", self.inspect(lhs), self.inspect(rhs))
            }
        }
    }

    pub fn eval_z(&mut self) -> i64 {
        let mut z = 0;
        for i in 0..=99 {
            let z_wire = Wire([b'z', b'0' + (i / 10), b'0' + (i % 10)]);
            if !self.wires.contains_key(&z_wire) {
                break;
            }

            z |= (self.eval(z_wire) as i64) << i;
        }
        z
    }

    pub fn eval(&mut self, wire: Wire) -> u8 {
        match *self.wires.get(&wire).unwrap() {
            Expr::Value(bit) => bit,
            Expr::Gate(op, lhs, rhs) => op.eval(self.eval(lhs), self.eval(rhs)),
        }
    }
}

enum Expr {
    Value(u8),
    Gate(Op, Wire, Wire),
}

impl Debug for Expr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Expr::Value(bit) => write!(f, "{bit}"),
            Expr::Gate(op, lhs, rhs) => write!(f, "{lhs:?} {op:?} {rhs:?}"),
        }
    }
}

#[derive(Debug, Clone, Copy)]
enum Op {
    And,
    Or,
    Xor,
}

impl Op {
    pub fn eval(self, lhs: u8, rhs: u8) -> u8 {
        match self {
            Op::And => lhs & rhs,
            Op::Or => lhs | rhs,
            Op::Xor => lhs ^ rhs,
        }
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
struct Wire([u8; 3]);

impl TryFrom<&str> for Wire {
    type Error = ();

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let value = value.as_bytes();
        if value.len() == 3 {
            Ok(Self([value[0], value[1], value[2]]))
        } else {
            Err(())
        }
    }
}

impl Debug for Wire {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", std::str::from_utf8(&self.0).unwrap())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const SMALL_EXAMPLE: &str = "\
        x00: 1\n\
        x01: 1\n\
        x02: 1\n\
        y00: 0\n\
        y01: 1\n\
        y02: 0\n\
        \n\
        x00 AND y00 -> z00\n\
        x01 XOR y01 -> z01\n\
        x02 OR y02 -> z02\n\
        ";

    const LARGE_EXAMPLE: &str = "\
        x00: 1\n\
        x01: 0\n\
        x02: 1\n\
        x03: 1\n\
        x04: 0\n\
        y00: 1\n\
        y01: 1\n\
        y02: 1\n\
        y03: 1\n\
        y04: 1\n\
        \n\
        ntg XOR fgs -> mjb\n\
        y02 OR x01 -> tnw\n\
        kwq OR kpj -> z05\n\
        x00 OR x03 -> fst\n\
        tgd XOR rvg -> z01\n\
        vdt OR tnw -> bfw\n\
        bfw AND frj -> z10\n\
        ffh OR nrd -> bqk\n\
        y00 AND y03 -> djm\n\
        y03 OR y00 -> psh\n\
        bqk OR frj -> z08\n\
        tnw OR fst -> frj\n\
        gnj AND tgd -> z11\n\
        bfw XOR mjb -> z00\n\
        x03 OR x00 -> vdt\n\
        gnj AND wpb -> z02\n\
        x04 AND y00 -> kjc\n\
        djm OR pbm -> qhw\n\
        nrd AND vdt -> hwm\n\
        kjc AND fst -> rvg\n\
        y04 OR y02 -> fgs\n\
        y01 AND x02 -> pbm\n\
        ntg OR kjc -> kwq\n\
        psh XOR fgs -> tgd\n\
        qhw XOR tgd -> z09\n\
        pbm OR djm -> kpj\n\
        x03 XOR y03 -> ffh\n\
        x00 XOR y04 -> ntg\n\
        bfw OR bqk -> z06\n\
        nrd XOR fgs -> wpb\n\
        frj XOR qhw -> z04\n\
        bqk OR frj -> z07\n\
        y03 OR x01 -> nrd\n\
        hwm AND bqk -> z03\n\
        tgd XOR rvg -> z12\n\
        tnw OR pbm -> gnj\n\
        ";

    #[test]
    fn solve_part_one_small_example() {
        let input = Cursor::new(SMALL_EXAMPLE);
        assert_eq!(Solution::Num(4), solve(Part::One, input).unwrap());
    }

    #[test]
    #[ignore]
    fn solve_part_one_large_example() {
        let input = Cursor::new(LARGE_EXAMPLE);
        assert_eq!(Solution::Num(2024), solve(Part::One, input).unwrap());
    }

    #[test]
    #[ignore = "todo"]
    fn solve_part_one() {
        let input = file_reader("input/day24").unwrap();
        assert_eq!(Solution::Num(0), solve(Part::One, input).unwrap());
    }

    #[test]
    #[ignore = "todo"]
    fn solve_part_two_example() {
        let input = Cursor::new("");
        assert_eq!(Solution::Num(0), solve(Part::Two, input).unwrap());
    }

    #[test]
    #[ignore = "todo"]
    fn solve_part_two() {
        let input = file_reader("input/day24").unwrap();
        assert_eq!(Solution::Num(0), solve(Part::Two, input).unwrap());
    }
}
