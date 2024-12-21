use std::{collections::HashMap, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let (towel_set, designs) = parse(input)?;

    let solution = match part {
        Part::One => designs
            .iter()
            .filter(|design| towel_set.count_recipes(design) > 0)
            .count() as i64,
        Part::Two => designs
            .iter()
            .map(|design| towel_set.count_recipes(design))
            .sum(),
    };

    Ok(Solution::Num(solution))
}

fn parse(mut input: impl BufRead) -> color_eyre::Result<(TowelSet, Vec<Vec<u8>>)> {
    let mut line = String::new();
    input.read_line(&mut line)?;

    let patterns: Vec<_> = line
        .split(',')
        .map(|pat| pat.trim().as_bytes().to_vec())
        .collect();

    let designs = input
        .lines()
        .map(|line| line.unwrap().trim().as_bytes().to_vec())
        .filter(|line| !line.is_empty())
        .collect();

    Ok((TowelSet::new(&patterns), designs))
}

struct TowelSet {
    patterns: HashMap<u8, Vec<Vec<u8>>>,
}

impl TowelSet {
    pub fn new(patterns_list: &[Vec<u8>]) -> Self {
        let mut patterns = HashMap::new();
        for pattern in patterns_list {
            patterns
                .entry(pattern[0])
                .or_insert_with(Vec::new)
                .push(pattern.clone());
        }

        Self { patterns }
    }

    pub fn count_recipes(&self, design: &[u8]) -> i64 {
        self.count_recipes_aux(design, &mut HashMap::new())
    }

    fn count_recipes_aux(&self, design: &[u8], cache: &mut HashMap<Vec<u8>, i64>) -> i64 {
        if design.is_empty() {
            return 1;
        }

        let design = design.to_vec();

        if let Some(&count) = cache.get(&design) {
            return count;
        }

        let mut count = 0;
        if let Some(patterns) = self.patterns.get(&design[0]) {
            for pattern in patterns.iter() {
                if design.starts_with(pattern) {
                    count += self.count_recipes_aux(&design[pattern.len()..], cache);
                }
            }
        }

        cache.insert(design, count);
        count
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        r, wr, b, g, bwu, rb, gb, br\n\
        \n\
        brwrr\n\
        bggr\n\
        gbbr\n\
        rrbgbr\n\
        ubwu\n\
        bwurrg\n\
        brgr\n\
        bbrgwb\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(6), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day19").unwrap();
        assert_eq!(Solution::Num(317), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(16), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day19").unwrap();
        assert_eq!(
            Solution::Num(883443544805484),
            solve(Part::Two, input).unwrap()
        );
    }
}
