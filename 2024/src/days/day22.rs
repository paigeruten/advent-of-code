use std::{collections::HashMap, io::BufRead, iter::successors};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let secret_numbers = parse(input);

    let solution = match part {
        Part::One => secret_numbers
            .iter()
            .map(|&secret_number| {
                successors(Some(secret_number), |&n| Some(evolve(n)))
                    .nth(2000)
                    .unwrap()
            })
            .sum(),
        Part::Two => {
            let mut overall_price_map = HashMap::new();

            for secret_number in secret_numbers {
                let price_map = get_price_map(secret_number);
                for (changes, price) in price_map.into_iter() {
                    *overall_price_map.entry(changes).or_insert(0) += price;
                }
            }

            overall_price_map.into_values().max().unwrap()
        }
    };

    Ok(Solution::Num(solution))
}

fn parse(input: impl BufRead) -> Vec<i64> {
    input
        .lines()
        .map(|line| line.unwrap().trim().parse().unwrap())
        .collect()
}

fn evolve(mut number: i64) -> i64 {
    const PERIOD: i64 = 16777216;
    number = ((number << 6) ^ number) % PERIOD;
    number = ((number >> 5) ^ number) % PERIOD;
    ((number << 11) ^ number) % PERIOD
}

fn get_price_map(mut number: i64) -> HashMap<(i8, i8, i8, i8), i64> {
    let mut price_map = HashMap::new();
    let mut changes = (0, 0, 0, 0);
    let mut last_number;
    for i in 0..2000 {
        last_number = number;
        number = evolve(number);

        changes = (
            changes.1,
            changes.2,
            changes.3,
            ((number % 10) - (last_number % 10)) as i8,
        );

        if i >= 3 {
            price_map.entry(changes).or_insert(number % 10);
        }
    }

    price_map
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const FIRST_EXAMPLE: &str = "\
        1\n\
        10\n\
        100\n\
        2024\n\
        ";

    const SECOND_EXAMPLE: &str = "\
        1\n\
        2\n\
        3\n\
        2024\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(FIRST_EXAMPLE);
        assert_eq!(Solution::Num(37327623), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day22").unwrap();
        assert_eq!(Solution::Num(19458130434), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(SECOND_EXAMPLE);
        assert_eq!(Solution::Num(23), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day22").unwrap();
        assert_eq!(Solution::Num(2130), solve(Part::Two, input).unwrap());
    }
}
