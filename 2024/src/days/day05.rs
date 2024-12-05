use nom::{
    character::complete::{char, digit1, line_ending},
    combinator::{map, map_res},
    multi::{count, separated_list1},
    sequence::separated_pair,
    IResult, Parser,
};
use std::{
    cmp::Ordering,
    collections::{HashMap, HashSet},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let (rules, updates) = parse(input)?;
    let ruleset = RuleSet::from_rules(&rules);

    let (correctly_ordered, incorrectly_ordered) = updates
        .iter()
        .partition::<Vec<_>, _>(|update| update.is_correctly_ordered(&ruleset));

    let solution = match part {
        Part::One => correctly_ordered
            .iter()
            .map(|update| update.middle_page())
            .sum(),
        Part::Two => incorrectly_ordered
            .iter()
            .map(|update| update.fix_ordering(&ruleset).middle_page())
            .sum(),
    };

    Ok(Solution::Num(solution))
}

fn integer(i: &str) -> IResult<&str, i64> {
    map_res(digit1, |s: &str| s.parse::<i64>())(i)
}

fn ordering_rule(i: &str) -> IResult<&str, Rule> {
    map(
        separated_pair(integer, char('|'), integer),
        |(before, after)| Rule { before, after },
    )(i)
}

fn update(i: &str) -> IResult<&str, Update> {
    map(separated_list1(char(','), integer), |pages| Update {
        pages,
    })(i)
}

fn parse(mut input: impl BufRead) -> color_eyre::Result<(Vec<Rule>, Vec<Update>)> {
    let mut input_str = String::new();
    input.read_to_string(&mut input_str)?;

    let (_, (rules, updates)) = separated_pair(
        separated_list1(line_ending, ordering_rule),
        count(line_ending, 2),
        separated_list1(line_ending, update),
    )
    .parse(input_str.as_str())
    .map_err(|err| err.to_owned())?;

    Ok((rules, updates))
}

#[derive(Debug, Clone, Copy)]
struct Rule {
    before: i64,
    after: i64,
}

#[derive(Debug, Clone)]
struct Update {
    pages: Vec<i64>,
}

impl Update {
    pub fn is_correctly_ordered(&self, ruleset: &RuleSet) -> bool {
        let pages = &self.pages;
        for i in (0..pages.len()).rev() {
            let page = pages[i];
            if let Some(afters) = ruleset.0.get(&page) {
                if pages[0..i].iter().any(|before| afters.contains(before)) {
                    return false;
                }
            }
        }
        true
    }

    pub fn fix_ordering(&self, ruleset: &RuleSet) -> Update {
        let mut pages = self.pages.clone();
        pages.sort_by(
            |a, b| match ruleset.0.get(a).map(|afters| afters.contains(b)) {
                Some(true) => Ordering::Less,
                _ => Ordering::Greater,
            },
        );
        Update { pages }
    }

    pub fn middle_page(&self) -> i64 {
        self.pages[self.pages.len() / 2]
    }
}

#[derive(Debug)]
struct RuleSet(HashMap<i64, HashSet<i64>>);

impl RuleSet {
    pub fn from_rules(rules: &[Rule]) -> Self {
        let mut ruleset = HashMap::new();

        for &Rule { before, after } in rules.iter() {
            ruleset
                .entry(before)
                .or_insert_with(HashSet::new)
                .insert(after);
        }

        Self(ruleset)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        47|53\n\
        97|13\n\
        97|61\n\
        97|47\n\
        75|29\n\
        61|13\n\
        75|53\n\
        29|13\n\
        97|29\n\
        53|29\n\
        61|53\n\
        97|53\n\
        61|29\n\
        47|13\n\
        75|47\n\
        97|75\n\
        47|61\n\
        75|61\n\
        47|29\n\
        75|13\n\
        53|13\n\
        \n\
        75,47,61,53,29\n\
        97,61,53,29,13\n\
        75,29,13\n\
        75,97,47,61,53\n\
        61,13,29\n\
        97,13,75,29,47\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(143), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day05").unwrap();
        assert_eq!(Solution::Num(5275), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(123), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day05").unwrap();
        assert_eq!(Solution::Num(6191), solve(Part::Two, input).unwrap());
    }
}
