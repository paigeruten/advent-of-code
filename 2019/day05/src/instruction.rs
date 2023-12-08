use num_enum::TryFromPrimitive;
use smallvec::SmallVec;
use std::convert::TryFrom;
use std::fmt;

#[derive(Debug, Eq, PartialEq, TryFromPrimitive, Copy, Clone)]
#[repr(u8)]
pub enum Opcode {
    Add  = 1,
    Mul  = 2,
    In   = 3,
    Out  = 4,
    JmpT = 5,
    JmpF = 6,
    Lt   = 7,
    Eql  = 8,
    Halt = 99,
}

impl Opcode {
    /// How many ints an instruction of this opcode takes up (so, number of
    /// parameters plus one).
    pub fn length(self) -> usize {
        use Opcode::*;

        match self {
            Add | Mul | Lt | Eql => 4,
            In | Out => 2,
            JmpT | JmpF => 3,
            Halt => 1,
        }
    }
}

impl fmt::Display for Opcode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        use Opcode::*;

        match self {
            Add  => write!(f, "Add"),
            Mul  => write!(f, "Mul"),
            In   => write!(f, "In"),
            Out  => write!(f, "Out"),
            JmpT => write!(f, "JmpT"),
            JmpF => write!(f, "JmpF"),
            Lt   => write!(f, "Lt"),
            Eql  => write!(f, "Eql"),
            Halt => write!(f, "Halt"),
        }
    }
}

#[derive(Debug, Eq, PartialEq, TryFromPrimitive, Copy, Clone)]
#[repr(u8)]
pub enum ParameterMode {
    Position  = 0,
    Immediate = 1,
}

#[derive(Debug)]
pub struct Instruction {
    opcode: Opcode,
    param_modes: SmallVec<[ParameterMode; 3]>,
}

impl TryFrom<i32> for Instruction {
    type Error = ();

    fn try_from(value: i32) -> Result<Self, Self::Error> {
        let opcode = Opcode::try_from((value % 100) as u8)
            .map_err(|_| ())?;
        let param_modes = (1..opcode.length())
            .map(|i| {
                let place = 10_i32.pow(i as u32 + 1);
                let digit = (value / place % 10) as u8;
                ParameterMode::try_from(digit)
            })
            .collect::<Result<_, _>>()
            .map_err(|_| ())?;

        Ok(Instruction { opcode, param_modes })
    }
}

impl Instruction {
    pub fn opcode(&self) -> Opcode {
        self.opcode
    }

    pub fn length(&self) -> usize {
        self.opcode.length()
    }

    pub fn param_mode(&self, param: usize) -> ParameterMode {
        self.param_modes[param]
    }

    pub fn disassemble(&self, code: &[i32]) {
        use Opcode::*;

        print!("{:20}", code.iter()
                            .map(i32::to_string)
                            .collect::<Vec<_>>()
                            .join(","));
        print!("{}", self.opcode);

        match self.opcode {
            Add  => println!(": {} = {} + {}",
                             self.disassemble_param(2, code),
                             self.disassemble_param(0, code),
                             self.disassemble_param(1, code)),
            Mul  => println!(": {} = {} * {}",
                             self.disassemble_param(2, code),
                             self.disassemble_param(0, code),
                             self.disassemble_param(1, code)),
            In   => println!(": {} = (input)",
                             self.disassemble_param(0, code)),
            Out  => println!(": {}",
                            self.disassemble_param(0, code)),
            JmpT => println!(": goto {} if {} != 0",
                            self.disassemble_param(1, code),
                            self.disassemble_param(0, code)),
            JmpF => println!(": goto {} if {} == 0",
                            self.disassemble_param(1, code),
                            self.disassemble_param(0, code)),
            Lt   => println!(": {} = {} < {} ? 1 : 0",
                             self.disassemble_param(2, code),
                             self.disassemble_param(0, code),
                             self.disassemble_param(1, code)),
            Eql  => println!(": {} = {} == {} ? 1 : 0",
                             self.disassemble_param(2, code),
                             self.disassemble_param(0, code),
                             self.disassemble_param(1, code)),
            _    => println!(),
        }
    }

    fn disassemble_param(&self, param: usize, code: &[i32]) -> String {
        use ParameterMode::*;

        match self.param_modes[param] {
            Position  => format!("mem[{}]", code[param + 1]),
            Immediate => format!("{}", code[param + 1]),
        }
    }
}
