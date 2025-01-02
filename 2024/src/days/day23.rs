use std::{
    collections::HashMap,
    fmt::{Debug, Display},
    io::BufRead,
};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let network = Network::parse(input)?;

    Ok(match part {
        Part::One => {
            let computers: Vec<Computer> = network.graph.keys().copied().collect();

            let mut num_connected_groups = 0;
            for i in 0..(computers.len() - 2) {
                let comp1 = computers[i];
                for j in (i + 1)..(computers.len() - 1) {
                    let comp2 = computers[j];
                    if !network.is_connected(comp1, comp2) {
                        continue;
                    }
                    for &comp3 in computers[(j + 1)..].iter() {
                        if !comp1.starts_with(b't')
                            && !comp2.starts_with(b't')
                            && !comp3.starts_with(b't')
                        {
                            continue;
                        }
                        if network.is_connected(comp1, comp3) && network.is_connected(comp2, comp3)
                        {
                            num_connected_groups += 1;
                        }
                    }
                }
            }
            Solution::Num(num_connected_groups)
        }

        Part::Two => {
            let mut largest_set = network
                .graph
                .keys()
                .map(|&comp| network.largest_set_containing(comp))
                .max_by_key(|set| set.len())
                .unwrap();

            largest_set.sort();
            let password = largest_set
                .iter()
                .map(|computer| format!("{computer}"))
                .collect::<Vec<String>>()
                .join(",");

            Solution::Str(password)
        }
    })
}

#[derive(Debug)]
struct Network {
    graph: HashMap<Computer, Vec<Computer>>,
}

impl Network {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut graph = HashMap::new();

        for line in input.lines() {
            let line = line?;
            let line = line.as_bytes();
            if line.len() == 5 && line[2] == b'-' {
                let left = Computer(line[0], line[1]);
                let right = Computer(line[3], line[4]);

                graph.entry(left).or_insert_with(Vec::new).push(right);
                graph.entry(right).or_insert_with(Vec::new).push(left);
            }
        }

        Ok(Self { graph })
    }

    pub fn is_connected(&self, a: Computer, b: Computer) -> bool {
        self.graph
            .get(&a)
            .map(|neighbours| neighbours.contains(&b))
            .unwrap_or(false)
    }

    pub fn is_all_connected(&self, computers: &[Computer]) -> bool {
        for i in 0..(computers.len() - 1) {
            for j in (i + 1)..computers.len() {
                if !self.is_connected(computers[i], computers[j]) {
                    return false;
                }
            }
        }
        true
    }

    pub fn largest_set_containing(&self, comp: Computer) -> Vec<Computer> {
        let mut computers = self.graph.get(&comp).cloned().unwrap_or_default();
        computers.push(comp);

        let mut sets = vec![computers];
        while !sets.is_empty() {
            let mut next_sets = Vec::new();
            for set in sets.drain(..) {
                if self.is_all_connected(&set) {
                    return set;
                }

                for i in 0..set.len() {
                    let mut next_set = set.clone();
                    next_set.remove(i);
                    next_sets.push(next_set);
                }
            }
            sets = next_sets;
        }

        unreachable!()
    }
}

#[derive(Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
struct Computer(u8, u8);

impl Computer {
    pub fn starts_with(self, ch: u8) -> bool {
        self.0 == ch
    }
}

impl Debug for Computer {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}{}", char::from(self.0), char::from(self.1))
    }
}

impl Display for Computer {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}{}", char::from(self.0), char::from(self.1))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "\
        kh-tc\n\
        qp-kh\n\
        de-cg\n\
        ka-co\n\
        yn-aq\n\
        qp-ub\n\
        cg-tb\n\
        vc-aq\n\
        tb-ka\n\
        wh-tc\n\
        yn-cg\n\
        kh-ub\n\
        ta-co\n\
        de-co\n\
        tc-td\n\
        tb-wq\n\
        wh-td\n\
        ta-ka\n\
        td-qp\n\
        aq-cg\n\
        wq-ub\n\
        ub-vc\n\
        de-ta\n\
        wq-aq\n\
        wq-vc\n\
        wh-yn\n\
        ka-de\n\
        kh-ta\n\
        co-tc\n\
        wh-qp\n\
        tb-vc\n\
        td-yn\n\
        ";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(7), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day23").unwrap();
        assert_eq!(Solution::Num(1308), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(
            Solution::Str("co,de,ka,ta".into()),
            solve(Part::Two, input).unwrap()
        );
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day23").unwrap();
        assert_eq!(
            Solution::Str("bu,fq,fz,pn,rr,st,sv,tr,un,uy,zf,zi,zy".into()),
            solve(Part::Two, input).unwrap()
        );
    }
}
