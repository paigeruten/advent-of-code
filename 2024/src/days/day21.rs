use std::{cmp::Ordering, collections::HashMap, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let codes = parse(input);

    let num_layers = match part {
        Part::One => 2,
        Part::Two => 25,
    };

    let solution = codes
        .iter()
        .map(|code| {
            let code_str: String = code.iter().map(|&key| char::from(key)).collect();
            let numeric_part = code_str.trim_start_matches('0').trim_end_matches('A');

            let shortest_length =
                KeyPad::Numeric.find_shortest_input_length(code, num_layers + 1) as i64;

            shortest_length * numeric_part.parse::<i64>().unwrap()
        })
        .sum();

    Ok(Solution::Num(solution))
}

fn parse(input: impl BufRead) -> Vec<Vec<Key>> {
    input
        .lines()
        .map(|line| {
            line.unwrap()
                .chars()
                .filter_map(|ch| ch.try_into().ok())
                .collect()
        })
        .collect()
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum KeyPad {
    Numeric,
    Directional,
}

impl KeyPad {
    pub fn find_shortest_input_length(self, output: &[Key], layers: usize) -> usize {
        let mut memo = HashMap::new();
        self.find_shortest_input_length_aux(output, layers, &mut memo)
    }

    pub fn find_shortest_input_length_aux(
        self,
        output: &[Key],
        layers: usize,
        memo: &mut HashMap<(KeyPad, Vec<Key>, usize), usize>,
    ) -> usize {
        if layers == 0 {
            return output.len();
        }

        let cache_key = (self, output.to_vec(), layers);
        if let Some(&length) = memo.get(&cache_key) {
            return length;
        }

        let mut length = 0;
        let mut position = Key::Activate;
        for &next_key in output {
            length += self
                .generate_instructions(position, next_key)
                .into_iter()
                .map(|instructions| {
                    KeyPad::Directional.find_shortest_input_length_aux(
                        &instructions,
                        layers - 1,
                        memo,
                    )
                })
                .min()
                .unwrap();
            position = next_key;
        }

        memo.insert(cache_key, length);

        length
    }

    fn generate_instructions(self, from: Key, to: Key) -> Vec<Vec<Key>> {
        let (x1, y1) = self.key_position(from);
        let (x2, y2) = self.key_position(to);
        let (dx, dy) = (x2 - x1, y2 - y1);

        let (move1, move2) = match (dx.cmp(&0), dy.cmp(&0)) {
            // We're already there, no moving needed.
            (Ordering::Equal, Ordering::Equal) => return vec![vec![Key::Activate]],

            // Only need to move in one dimension.
            (Ordering::Less, Ordering::Equal) => ((Key::Left, -dx), None),
            (Ordering::Greater, Ordering::Equal) => ((Key::Right, dx), None),
            (Ordering::Equal, Ordering::Less) => ((Key::Up, -dy), None),
            (Ordering::Equal, Ordering::Greater) => ((Key::Down, dy), None),

            // Need to move in two dimensions.
            (Ordering::Less, Ordering::Less) => ((Key::Up, -dy), Some((Key::Left, -dx))),
            (Ordering::Less, Ordering::Greater) => ((Key::Down, dy), Some((Key::Left, -dx))),
            (Ordering::Greater, Ordering::Less) => ((Key::Right, dx), Some((Key::Up, -dy))),
            (Ordering::Greater, Ordering::Greater) => ((Key::Right, dx), Some((Key::Down, dy))),
        };

        let is_corner_missing = match self {
            KeyPad::Numeric => (y1 == 3 && x2 == 0) || (y2 == 3 && x1 == 0),
            KeyPad::Directional => (y1 == 0 && x2 == 0) || (y2 == 0 && x1 == 0),
        };

        let move_orders = match move2 {
            Some(move2) => {
                if is_corner_missing {
                    vec![vec![move1, move2]]
                } else {
                    vec![vec![move1, move2], vec![move2, move1]]
                }
            }
            None => vec![vec![move1]],
        };

        move_orders
            .iter()
            .map(|moves| {
                let mut instructions = Vec::new();
                for &(key, count) in moves.iter() {
                    for _ in 0..count {
                        instructions.push(key);
                    }
                }
                instructions.push(Key::Activate);
                instructions
            })
            .collect()
    }

    fn key_position(self, key: Key) -> (i64, i64) {
        match self {
            KeyPad::Numeric => match key {
                Key::Seven => (0, 0),
                Key::Eight => (1, 0),
                Key::Nine => (2, 0),
                Key::Four => (0, 1),
                Key::Five => (1, 1),
                Key::Six => (2, 1),
                Key::One => (0, 2),
                Key::Two => (1, 2),
                Key::Three => (2, 2),
                Key::Zero => (1, 3),
                Key::Activate => (2, 3),
                _ => unreachable!(),
            },
            KeyPad::Directional => match key {
                Key::Up => (1, 0),
                Key::Activate => (2, 0),
                Key::Left => (0, 1),
                Key::Down => (1, 1),
                Key::Right => (2, 1),
                _ => unreachable!(),
            },
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
enum Key {
    Activate,
    Up,
    Right,
    Down,
    Left,
    Zero,
    One,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
}

impl TryFrom<char> for Key {
    type Error = ();

    fn try_from(value: char) -> Result<Self, Self::Error> {
        Ok(match value {
            'A' => Key::Activate,
            '^' => Key::Up,
            '>' => Key::Right,
            'v' => Key::Down,
            '<' => Key::Left,
            '0' => Key::Zero,
            '1' => Key::One,
            '2' => Key::Two,
            '3' => Key::Three,
            '4' => Key::Four,
            '5' => Key::Five,
            '6' => Key::Six,
            '7' => Key::Seven,
            '8' => Key::Eight,
            '9' => Key::Nine,
            _ => return Err(()),
        })
    }
}

impl From<Key> for char {
    fn from(value: Key) -> Self {
        match value {
            Key::Activate => 'A',
            Key::Up => '^',
            Key::Right => '>',
            Key::Down => 'v',
            Key::Left => '<',
            Key::Zero => '0',
            Key::One => '1',
            Key::Two => '2',
            Key::Three => '3',
            Key::Four => '4',
            Key::Five => '5',
            Key::Six => '6',
            Key::Seven => '7',
            Key::Eight => '8',
            Key::Nine => '9',
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        029A\n\
        980A\n\
        179A\n\
        456A\n\
        379A\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(126384), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day21").unwrap();
        assert_eq!(Solution::Num(176452), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day21").unwrap();
        assert_eq!(
            Solution::Num(218309335714068),
            solve(Part::Two, input).unwrap()
        );
    }
}
