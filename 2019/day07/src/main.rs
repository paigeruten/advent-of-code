use day07::{Program, VM};
use std::io;
use std::thread;
use std::sync::mpsc;

fn run_amplifier_series(program: &Program, phases: &[i32]) -> i32 {
    // Create N channels for N amplifiers. The amplifier with index M will take
    // input from receivers[M] and send output to senders[M + 1].
    let (senders, receivers): (Vec<_>, Vec<_>) =
        (0..phases.len())
        .map(|_| mpsc::channel())
        .unzip();

    // The last amplifier will send output to last_sender.
    let (last_sender, last_receiver) = mpsc::channel();

    let mut threads = Vec::with_capacity(phases.len());
    for (idx, input_receiver) in receivers.into_iter().enumerate() {
        let phase = phases[idx];
        let program = program.clone();

        let output_sender = if idx == phases.len() - 1 {
            last_sender.clone()
        } else {
            senders[idx + 1].clone()
        };

        // Send the amplifier its phase number.
        senders[idx].send(phase).unwrap();

        let thread_builder = thread::Builder::new()
            .name(format!("{:?}/{}", phases, phase));

        threads.push(thread_builder.spawn(move || {
            let mut vm = VM::new(input_receiver, output_sender);
            vm.load_program(&program);
            vm.execute();
        }).unwrap());
    }

    // Make sure last_sender "hangs up" on the channel when its amplifier has
    // halted, so our feedback thread knows when to quit.
    drop(last_sender);

    // Send the initial input of 0 to the first amplifier.
    senders[0].send(0).unwrap();

    // Create a "feedback" thread, which reads the output from the last
    // amplifier, and sends it back to the first amplifier, as well as to a
    // final output channel so we can grab the final output value at the end.
    let (final_output_sender, final_output_receiver) = mpsc::channel();
    let feedback_sender = senders[0].clone();
    let thread_builder = thread::Builder::new()
        .name(format!("{:?}/feedback", phases));
    threads.push(thread_builder.spawn(move || {
        for value in last_receiver.iter() {
            let _ = feedback_sender.send(value);
            final_output_sender.send(value).unwrap();
        }
    }).unwrap());

    for thread in threads {
        let _ = thread.join();
    }

    final_output_receiver.try_iter().last().unwrap()
}

fn next_combination(ary: &mut [i32]) -> bool {
    // 1. Find the least significant digit that has at least one larger digit
    // somewhere to its right.
    let mut i = ary.len() - 2;
    loop {
        if ary[i] < ary[i + 1] {
            break;
        } else if i == 0 {
            // No more combinations!
            return false;
        }

        i -= 1;
    }

    // 2. Find the next largest digit to the right of the digit we found.
    let mut next_highest = i + 1;
    for j in i+1 .. ary.len() {
        if ary[j] > ary[i] && ary[j] < ary[next_highest] {
            next_highest = j;
        }
    }

    // 3. Swap those two digits.
    ary.swap(i, next_highest);

    // 4. Sort the digits to the right of the one we swapped. Because we're
    // calling sort() soooo often and with tiny arrays, I felt the need to
    // special-case arrays of length <=3...
    let right_of_i = &mut ary[i+1..];
    match right_of_i.len() {
        0 | 1 => {},
        2 => right_of_i.swap(0, 1),
        3 => {
            let (a, b, c) = (right_of_i[0], right_of_i[1], right_of_i[2]);
            match (a < b, a < c, b < c) {
                (true, true, true) => {}
                (true, true, false) => { right_of_i[1] = c; right_of_i[2] = b; }
                (false, true, true) => { right_of_i[0] = b; right_of_i[1] = a; }
                (false, false, true) => { right_of_i[0] = b; right_of_i[1] = c; right_of_i[2] = a; }
                (true, false, false) => { right_of_i[0] = c; right_of_i[1] = a; right_of_i[2] = b; }
                (false, false, false) => { right_of_i[0] = c; right_of_i[2] = a; }
                (false, true, false) => unreachable!(),
                (true, false, true) => unreachable!(),
            };
        }
        _ => right_of_i.sort(),
    };

    true
}

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let program = line.parse::<Program>().unwrap();

    // Part 1
    let mut phases = [0, 1, 2, 3, 4];
    let mut highest_output = 0;
    loop {
        let output = run_amplifier_series(&program, &phases);
        if output > highest_output {
            highest_output = output;
        }

        if !next_combination(&mut phases) {
            break;
        }
    }
    println!("Highest output (part 1): {}", highest_output);

    // Part 2
    let mut phases = [5, 6, 7, 8, 9];
    let mut highest_output = 0;
    loop {
        let output = run_amplifier_series(&program, &phases);
        if output > highest_output {
            highest_output = output;
        }

        if !next_combination(&mut phases) {
            break;
        }
    }
    println!("Highest output (part 2): {}", highest_output);
}
