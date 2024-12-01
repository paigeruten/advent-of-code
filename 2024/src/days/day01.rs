use std::{
    collections::HashMap,
    io::{read_to_string, BufRead},
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let input = read_to_string(input)?;
    let (left_list, right_list) = parse_lists(&input);

    let solution = match part {
        Part::One => total_distance(left_list, right_list),
        Part::Two => similarity_score(left_list, right_list),
    };

    Ok(Solution::Num(solution))
}

fn parse_lists(input: &str) -> (Vec<LocationId>, Vec<LocationId>) {
    input
        .lines()
        .map(|line| {
            let mut ids = line
                .split_ascii_whitespace()
                .map(|id| LocationId(id.parse().expect("Could not parse location id")));
            (ids.next().unwrap(), ids.next().unwrap())
        })
        .unzip()
}

fn total_distance(mut left_list: Vec<LocationId>, mut right_list: Vec<LocationId>) -> i64 {
    assert_eq!(left_list.len(), right_list.len());

    left_list.sort();
    right_list.sort();

    left_list
        .into_iter()
        .zip(right_list)
        .map(|(left, right)| left.distance(right))
        .sum()
}

fn similarity_score(left_list: Vec<LocationId>, right_list: Vec<LocationId>) -> i64 {
    let mut appearances = HashMap::new();
    for location_id in right_list.into_iter() {
        *appearances.entry(location_id).or_insert(0) += 1;
    }

    left_list
        .iter()
        .map(|location_id| location_id.0 * appearances.get(location_id).unwrap_or(&0))
        .sum()
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord, Hash)]
struct LocationId(i64);

impl LocationId {
    pub fn distance(self, other: LocationId) -> i64 {
        (self.0 - other.0).abs()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        3   4\n\
        4   3\n\
        2   5\n\
        1   3\n\
        3   9\n\
        3   3\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(11), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day01").unwrap();
        assert_eq!(Solution::Num(2086478), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(31), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day01").unwrap();
        assert_eq!(Solution::Num(24941624), solve(Part::Two, input).unwrap());
    }
}
