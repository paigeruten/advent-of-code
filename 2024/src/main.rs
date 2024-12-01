use common::{file_reader, Part};
use days::{solve, NUM_DAYS};

mod common;
mod days;

fn main() -> color_eyre::Result<()> {
    color_eyre::install()?;

    if cfg!(debug_assertions) || cfg!(test) {
        std::env::set_var("RUST_BACKTRACE", "full");
    }

    let args: Vec<String> = std::env::args().collect();

    let day_numbers = if args.len() > 1 {
        vec![args[1]
            .parse::<usize>()
            .expect("Day number must be an integer")]
    } else {
        (1..=NUM_DAYS).collect()
    };

    let part_number = args.get(2).map(|num| {
        num.parse::<usize>()
            .expect("Part number must be an integer")
    });
    let parts = if let Some(part_number) = part_number {
        vec![part_number.try_into()?]
    } else {
        vec![Part::One, Part::Two]
    };

    let input_path = args.get(3);

    for &day_number in day_numbers.iter() {
        println!("\x1b[1mDay {day_number}\x1b[0m");
        for &part in parts.iter() {
            let input = file_reader(
                &input_path
                    .cloned()
                    .unwrap_or_else(|| format!("input/day{:02}", day_number)),
            )?;
            let solution = solve(day_number, part, input)?;
            println!("  Part {part}: {solution}");
        }
    }

    Ok(())
}
