use std::{
    fmt::Display,
    fs::File,
    io::{BufRead, BufReader},
};

#[derive(Copy, Clone, PartialEq)]
pub enum Part {
    One,
    Two,
}

impl Display for Part {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let part_num: usize = (*self).into();
        write!(f, "{}", part_num)
    }
}

impl From<Part> for usize {
    fn from(part: Part) -> Self {
        match part {
            Part::One => 1,
            Part::Two => 2,
        }
    }
}

impl TryFrom<usize> for Part {
    type Error = color_eyre::Report;

    fn try_from(value: usize) -> Result<Self, Self::Error> {
        match value {
            1 => Ok(Part::One),
            2 => Ok(Part::Two),
            _ => Err(color_eyre::eyre::eyre!(
                "Part number must be between 1 and 2"
            )),
        }
    }
}

#[derive(Debug, PartialEq)]
pub enum Solution {
    Num(i64),
    Str(String),
}

impl Display for Solution {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            Solution::Num(n) => n.fmt(f),
            Solution::Str(s) => s.fmt(f),
        }
    }
}

pub fn file_reader(path: &str) -> color_eyre::Result<impl BufRead> {
    Ok(BufReader::new(File::open(path)?))
}
