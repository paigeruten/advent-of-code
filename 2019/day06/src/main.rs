use std::collections::{HashMap, HashSet};
use std::io;
use std::io::BufRead;

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
struct SpaceObject([char; 3]);

struct OrbitPath(Vec<SpaceObject>);

fn parse_orbit(line: &str) -> (SpaceObject, SpaceObject) {
    let mut chars = line.chars();

    let orbitee = SpaceObject([
        chars.next().expect("Invalid line"),
        chars.next().expect("Invalid line"),
        chars.next().expect("Invalid line"),
    ]);

    if chars.next() != Some(')') {
        panic!("Invalid line");
    }

    let orbiter = SpaceObject([
        chars.next().expect("Invalid line"),
        chars.next().expect("Invalid line"),
        chars.next().expect("Invalid line"),
    ]);

    if chars.next() != None {
        panic!("Invalid line");
    }

    (orbiter, orbitee)
}

fn num_orbits_to_com(orbits: &HashMap<SpaceObject, SpaceObject>, object: SpaceObject) -> usize {
    let mut num_orbits = 0;
    let mut current = object;
    while let Some(orbitee) = orbits.get(&current) {
        num_orbits += 1;
        current = *orbitee;
    }
    num_orbits
}

fn orbitees(orbits: &HashMap<SpaceObject, SpaceObject>, orbiter: SpaceObject) -> Vec<SpaceObject> {
    let mut orbitees = Vec::new();
    let mut current = orbiter;
    while let Some(orbitee) = orbits.get(&current) {
        orbitees.push(*orbitee);
        current = *orbitee;
    }
    orbitees
}

fn main() {
    let mut orbits: HashMap<SpaceObject, SpaceObject> = HashMap::new();

    for line in io::stdin().lock().lines() {
        let (orbiter, orbitee) = parse_orbit(&line.unwrap().trim_end());
        orbits.insert(orbiter, orbitee);
    }

    let mut num_orbits = 0;
    for orbiter in orbits.keys() {
        num_orbits += num_orbits_to_com(&orbits, *orbiter);
    }

    println!("Number of orbits: {}", num_orbits);

    let you_path = orbitees(&orbits, SpaceObject(['Y', 'O', 'U']));
    let santa_path = orbitees(&orbits, SpaceObject(['S', 'A', 'N']));

    let mut santa_path_set = HashSet::with_capacity(you_path.len());
    for orbitee in santa_path.iter() {
        santa_path_set.insert(orbitee);
    }

    let mut common_orbitee = None;
    let mut path_len = 0;
    for orbitee in you_path.iter() {
        if santa_path_set.contains(orbitee) {
            common_orbitee = Some(orbitee);
            break;
        }
        path_len += 1;
    }

    for orbitee in santa_path.iter() {
        if Some(orbitee) == common_orbitee {
            break;
        }
        path_len += 1;
    }

    println!("Orbital transfers required: {}", path_len);
}
