use day13::{Program, VM, ExecuteStatus};
use num_enum::TryFromPrimitive;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::fmt;
use std::io;
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

#[derive(Debug, TryFromPrimitive, PartialEq, Eq, Copy, Clone)]
#[repr(u8)]
enum Tile {
    Empty  = 0,
    Wall   = 1,
    Block  = 2,
    Paddle = 3,
    Ball   = 4,
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        use Tile::*;

        match self {
            Empty  => write!(f, " "),
            Wall   => write!(f, "#"),
            Block  => write!(f, "@"),
            Paddle => write!(f, "="),
            Ball   => write!(f, "o"),
        }
    }
}

#[derive(Debug)]
struct Screen {
    tiles: HashMap<(i64, i64), Tile>,
}

impl Screen {
    pub fn new() -> Self {
        Screen { tiles: HashMap::new() }
    }
}

impl fmt::Display for Screen {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let min_x = self.tiles.keys().map(|&(x, _)| x).min().unwrap();
        let max_x = self.tiles.keys().map(|&(x, _)| x).max().unwrap();
        let min_y = self.tiles.keys().map(|&(_, y)| y).min().unwrap();
        let max_y = self.tiles.keys().map(|&(_, y)| y).max().unwrap();

        for y in min_y..=max_y {
            for x in min_x..=max_x {
                let tile = self.tiles.get(&(x, y))
                    .unwrap_or(&Tile::Empty);
                write!(f, "{}", tile)?;
            }
            writeln!(f)?;
        }

        Ok(())
    }
}

fn part1(program: &Program) {
    let (_input_sender, input_receiver) = mpsc::channel();
    let (output_sender, output_receiver) = mpsc::channel();
    let mut vm = VM::new(input_receiver, output_sender);
    vm.pause_after_output = true;

    vm.load_program(&program);

    let mut screen = Screen::new();

    loop {
        match vm.execute() {
            ExecuteStatus::PausedAfterOutput => {
                assert_eq!(vm.execute(), ExecuteStatus::PausedAfterOutput);
                assert_eq!(vm.execute(), ExecuteStatus::PausedAfterOutput);

                let x = output_receiver.recv().unwrap();
                let y = output_receiver.recv().unwrap();
                let tile = Tile::try_from(output_receiver.recv().unwrap() as u8)
                    .expect("Invalid tile");

                screen.tiles.insert((x, y), tile);
            }
            ExecuteStatus::WaitingForInput => unreachable!(),
            ExecuteStatus::Halted => break,
        }
    }

    println!("{}", screen);

    let num_blocks = screen.tiles.values()
        .filter(|&&tile| tile == Tile::Block)
        .count();

    println!("Number of blocks: {}", num_blocks);
}

fn part2(program: &Program, display: bool) {
    let (input_sender, input_receiver) = mpsc::channel();
    let (output_sender, output_receiver) = mpsc::channel();
    let mut vm = VM::new(input_receiver, output_sender);
    vm.pause_after_output = true;

    vm.load_program(&program);
    vm.patch_program(0, 2);

    let mut screen = Screen::new();
    let mut score = 0;
    let mut ball_x = 0;
    let mut paddle_x = 0;

    loop {
        match vm.execute() {
            ExecuteStatus::PausedAfterOutput => {
                assert_eq!(vm.execute(), ExecuteStatus::PausedAfterOutput);
                assert_eq!(vm.execute(), ExecuteStatus::PausedAfterOutput);

                let x = output_receiver.recv().unwrap();
                let y = output_receiver.recv().unwrap();

                if x == -1 && y == 0 {
                    score = output_receiver.recv().unwrap();
                } else {
                    let tile = Tile::try_from(output_receiver.recv().unwrap() as u8)
                        .expect("Invalid tile");

                    if tile == Tile::Ball {
                        ball_x = x;
                    } else if tile == Tile::Paddle {
                        paddle_x = x;
                    }

                    screen.tiles.insert((x, y), tile);
                }

                if display && score > 0 {
                    println!("{}", screen);
                    println!("Score: {}", score);

                    thread::sleep(Duration::from_millis(10));
                }
            }
            ExecuteStatus::WaitingForInput => {
                let input = if paddle_x < ball_x {
                    1
                } else if paddle_x > ball_x {
                    -1
                } else {
                    0
                };
                input_sender.send(input).unwrap();
            }
            ExecuteStatus::Halted => break,
        }
    }

    println!("Final score: {}", score);
}

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let program = line.parse::<Program>().unwrap();

    part1(&program);
    part2(&program, false);
}
