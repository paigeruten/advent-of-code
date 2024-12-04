use std::io::BufRead;

use crate::common::{Part, Solution};

mod day01;
mod day02;
mod day03;
mod day04;

pub const NUM_DAYS: usize = 4;

pub fn solve(day_number: usize, part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    match day_number {
        1 => day01::solve(part, input),
        2 => day02::solve(part, input),
        3 => day03::solve(part, input),
        4 => day04::solve(part, input),
        _ => Err(color_eyre::eyre::eyre!("That day has not been solved yet.")),
    }
}
