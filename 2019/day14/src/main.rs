use std::collections::HashMap;
use std::io::{self, BufRead};
use std::str::FromStr;

type Chemical = String;

#[derive(Debug)]
struct ChemicalQuantity {
    chemical: Chemical,
    quantity: u64,
}

impl FromStr for ChemicalQuantity {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut parts = s.split(' ');
        let quantity: u64 = parts.next().ok_or(())?.parse().or(Err(()))?;
        let chemical = parts.next().ok_or(())?.to_string();
        if parts.next() != None { return Err(()); }
        Ok(ChemicalQuantity { chemical, quantity })
    }
}

#[derive(Debug)]
struct Reaction {
    inputs: Vec<ChemicalQuantity>,
    output: ChemicalQuantity,
}

impl FromStr for Reaction {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut parts = s.split(" => ");
        let inputs: Vec<ChemicalQuantity> = parts.next().ok_or(())?
            .split(", ")
            .map(str::parse)
            .collect::<Result<_, _>>()?;
        let output: ChemicalQuantity = parts.next().ok_or(())?.parse()?;
        if parts.next() != None { return Err(()); }
        Ok(Reaction { inputs, output })
    }
}

fn ore_needed_for_fuel(reactions: &HashMap<Chemical, Reaction>, fuel_quantity: u64) -> u64 {
    let mut need: HashMap<Chemical, u64> = HashMap::new();
    let mut leftovers: HashMap<Chemical, u64> = HashMap::new();

    need.insert("FUEL".to_string(), fuel_quantity);

    loop {
        if need.len() == 1 && need.contains_key("ORE") {
            break;
        }

        let (chemical, &(mut needed)) = need.iter()
            .find(|(chemical, _)| *chemical != "ORE")
            .unwrap();
        let chemical = chemical.clone();

        if let Some(&(mut leftover)) = leftovers.get(&chemical) {
            if leftover >= needed {
                leftover -= needed;
                needed = 0;
            } else {
                needed -= leftover;
                leftover = 0;
            }
            *leftovers.get_mut(&chemical).unwrap() = leftover;
        }

        if needed > 0 {
            let reaction = reactions.get(&chemical).unwrap();
            let output_quantity = reaction.output.quantity;

            let reaction_times = if needed % output_quantity == 0 {
                needed / output_quantity
            } else {
                (needed / output_quantity) + 1
            };

            let leftover = (output_quantity * reaction_times) - needed;
            if leftover > 0 {
                if !leftovers.contains_key(&chemical) {
                    leftovers.insert(chemical.clone(), 0);
                }
                *leftovers.get_mut(&chemical).unwrap() += leftover;
            }

            for input in reaction.inputs.iter() {
                if !need.contains_key(&input.chemical) {
                    need.insert(input.chemical.clone(), 0);
                }
                *need.get_mut(&input.chemical).unwrap() += input.quantity * reaction_times;
            }
        }

        need.remove(&chemical);
    };

    *need.get("ORE").unwrap()
}

fn main() {
    let mut reactions: HashMap<Chemical, Reaction> = HashMap::new();

    for line in io::stdin().lock().lines() {
        let reaction: Reaction = line.unwrap().parse()
            .expect("Couldn't parse reaction");

        reactions.insert(reaction.output.chemical.clone(), reaction);
    }

    let ore_needed_for_1_fuel = ore_needed_for_fuel(&reactions, 1);

    println!("Ore needed for 1 fuel: {}", ore_needed_for_1_fuel);

    let mut lower_bound = 1_000_000_000_000 / ore_needed_for_1_fuel;
    let mut upper_bound = lower_bound + 1_000_000;

    while ore_needed_for_fuel(&reactions, upper_bound) <= 1_000_000_000_000 {
        lower_bound += 1_000_000;
        upper_bound += 1_000_000;
    }

    while lower_bound < upper_bound {
        let middle = (lower_bound + upper_bound) / 2;
        if ore_needed_for_fuel(&reactions, middle) > 1_000_000_000_000 {
            upper_bound = middle;
        } else {
            if lower_bound == middle {
                break;
            }
            lower_bound = middle;
        }
    }

    println!("Fuel produced by 1 trillion ore: {}", lower_bound);
}
