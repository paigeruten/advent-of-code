use std::io;

mod instruction;
mod vm;

use crate::vm::{Program, VM};

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let program = line.parse::<Program>().unwrap();

    let mut vm = VM::new(&program);
    vm.debug(true);
    vm.write_input(&[1]);
    vm.execute();
    println!();
    println!("Part 1 output: {:?}", vm.output());
    println!();

    let mut vm = VM::new(&program);
    vm.debug(true);
    vm.write_input(&[5]);
    vm.execute();
    println!();
    println!("Part 2 output: {:?}", vm.output());
}
