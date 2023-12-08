use day09::{Program, VM};
use std::io;
use std::sync::mpsc;

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let program = line.parse::<Program>().unwrap();

    let (input_tx, input_rx) = mpsc::channel();
    let (output_tx, output_rx) = mpsc::channel();
    let mut vm = VM::new(input_rx, output_tx);

    vm.load_program(&program);
    input_tx.send(1).unwrap();
    vm.execute();
    println!("Part 1 output: {:?}", (output_rx.try_iter().collect::<Vec<_>>()));

    vm.load_program(&program);
    input_tx.send(2).unwrap();
    vm.execute();
    println!("Part 2 output: {:?}", (output_rx.try_iter().collect::<Vec<_>>()));
}
