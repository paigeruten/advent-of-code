use day11::{Program, VM, ExecuteStatus};
use std::collections::HashMap;
use std::io;
use std::sync::mpsc;

#[derive(Debug, PartialEq, Eq)]
enum Color {
    Black,
    White,
}

fn print_tiles(tiles: &HashMap<(i32, i32), Color>) {
    let min_x = tiles.keys().map(|&(x, _)| x).min().unwrap();
    let max_x = tiles.keys().map(|&(x, _)| x).max().unwrap();
    let min_y = tiles.keys().map(|&(_, y)| y).min().unwrap();
    let max_y = tiles.keys().map(|&(_, y)| y).max().unwrap();

    for y in min_y..=max_y {
        for x in min_x..=max_x {
            if tiles.get(&(x, y)) == Some(&Color::White) {
                print!("#");
            } else {
                print!(".");
            }
        }
        println!();
    }
}

fn paint_the_thing(program: &Program, start_on_white_tile: bool) {
    let (input_sender, input_receiver) = mpsc::channel();
    let (output_sender, output_receiver) = mpsc::channel();
    let mut vm = VM::new(input_receiver, output_sender);
    vm.pause_after_output = true;

    vm.load_program(&program);

    let mut position: (i32, i32) = (0, 0);
    let mut direction: (i32, i32) = (0, -1);

    let mut painted_tiles: HashMap<(i32, i32), Color> = HashMap::new();

    if start_on_white_tile {
        painted_tiles.insert(position, Color::White);
    }

    loop {
        match vm.execute() {
            ExecuteStatus::WaitingForInput => {
                let color_code = match painted_tiles.get(&position) {
                    Some(Color::White) => 1,
                    _ => 0,
                };
                input_sender.send(color_code).unwrap();
            }

            ExecuteStatus::PausedAfterOutput => {
                assert_eq!(vm.execute(), ExecuteStatus::PausedAfterOutput);

                let color = match output_receiver.recv().unwrap() {
                    0 => Color::Black,
                    1 => Color::White,
                    _ => panic!("Invalid color input"),
                };

                painted_tiles.insert(position, color);

                match output_receiver.recv().unwrap() {
                    0 => {
                        // Turn left
                        direction = match direction {
                            (0, -1) => (-1, 0),
                            (-1, 0) => (0, 1),
                            (0, 1)  => (1, 0),
                            (1, 0)  => (0, -1),
                            _ => unreachable!(),
                        };
                    },
                    1 => {
                        // Turn right
                        direction = match direction {
                            (0, -1) => (1, 0),
                            (1, 0) => (0, 1),
                            (0, 1)  => (-1, 0),
                            (-1, 0)  => (0, -1),
                            _ => unreachable!(),
                        };
                    },
                    _ => panic!("Invalid direction input"),
                };

                position.0 += direction.0;
                position.1 += direction.1;
            }
            ExecuteStatus::Halted => break,
        }
    }

    println!("Number of painted tiles: {}", painted_tiles.len());
    println!();
    print_tiles(&painted_tiles);
    println!();
}

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let program = line.parse::<Program>().unwrap();

    paint_the_thing(&program, false);
    paint_the_thing(&program, true);
}
