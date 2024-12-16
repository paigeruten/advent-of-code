use std::io::BufRead;

use crate::common::{Part, Solution};

mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;
mod day08;
mod day09;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;
mod day15;
mod day16;

pub const NUM_DAYS: usize = 16;

pub fn solve(day_number: usize, part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    match day_number {
        1 => day01::solve(part, input),
        2 => day02::solve(part, input),
        3 => day03::solve(part, input),
        4 => day04::solve(part, input),
        5 => day05::solve(part, input),
        6 => day06::solve(part, input),
        7 => day07::solve(part, input),
        8 => day08::solve(part, input),
        9 => day09::solve(part, input),
        10 => day10::solve(part, input),
        11 => day11::solve(part, input),
        12 => day12::solve(part, input),
        13 => day13::solve(part, input),
        14 => day14::solve(part, input),
        15 => day15::solve(part, input),
        16 => day16::solve(part, input),
        _ => Err(color_eyre::eyre::eyre!("That day has not been solved yet.")),
    }
}
