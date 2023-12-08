use std::env;
use std::io;
use std::fs::File;
use std::process;

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
mod day17;
mod day18;
mod day19;

fn main() -> io::Result<()> {
  let args: Vec<String> = env::args().collect();

  if args.len() < 2 || args.len() > 3 {
    println!("Usage: {} <day number> [input file]", &args[0]);
    process::exit(1);
  }

  let day_number: u8 = args[1].parse()
    .expect("first argument must be a number");

  let file = match args.len() {
    3 => File::open(&args[2]),
    _ => File::open(format!("input/input{:02}", day_number))
  }.expect("input file doesn't exist");

  match day_number {
    1 => day01::solve(file),
    2 => day02::solve(file),
    3 => day03::solve(file),
    4 => day04::solve(file),
    5 => day05::solve(file),
    6 => day06::solve(file),
    7 => day07::solve(file),
    8 => day08::solve(file),
    9 => day09::solve(file),
    10 => day10::solve(file),
    11 => day11::solve(file),
    12 => day12::solve(file),
    13 => day13::solve(file),
    14 => day14::solve(file),
    15 => day15::solve(file),
    16 => day16::solve(file),
    17 => day17::solve(file),
    18 => day18::solve(file),
    19 => day19::solve(file),
    _ => panic!("Day {} not implemented yet", day_number)
  };

  Ok(())
}

