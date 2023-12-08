use std::collections::HashMap;

#[derive(Debug, PartialEq, Eq, Hash, Clone)]
struct Moon {
    position: (i64, i64, i64),
    velocity: (i64, i64, i64),
}

fn init_moons(positions: &[(i64, i64, i64)]) -> Vec<Moon> {
    positions.iter()
        .map(|&position| Moon { position, velocity: (0, 0, 0) })
        .collect()
}

fn simulate_step(moons: &mut [Moon]) {
    // Apply gravity between each pair of moons
    for i in 0..moons.len()-1 {
        for j in i+1..moons.len() {
            // Apply x gravity
            if moons[i].position.0 < moons[j].position.0 {
                moons[i].velocity.0 += 1;
                moons[j].velocity.0 -= 1;
            } else if moons[i].position.0 > moons[j].position.0 {
                moons[i].velocity.0 -= 1;
                moons[j].velocity.0 += 1;
            }

            // Apply y gravity
            if moons[i].position.1 < moons[j].position.1 {
                moons[i].velocity.1 += 1;
                moons[j].velocity.1 -= 1;
            } else if moons[i].position.1 > moons[j].position.1 {
                moons[i].velocity.1 -= 1;
                moons[j].velocity.1 += 1;
            }

            // Apply z gravity
            if moons[i].position.2 < moons[j].position.2 {
                moons[i].velocity.2 += 1;
                moons[j].velocity.2 -= 1;
            } else if moons[i].position.2 > moons[j].position.2 {
                moons[i].velocity.2 -= 1;
                moons[j].velocity.2 += 1;
            }
        }
    }

    // Apply velocity
    for i in 0..moons.len() {
        moons[i].position.0 += moons[i].velocity.0;
        moons[i].position.1 += moons[i].velocity.1;
        moons[i].position.2 += moons[i].velocity.2;
    }
}

fn find_repeating_step(moons: &mut [Moon]) -> usize {
    let mut x_step = None;
    let mut y_step = None;
    let mut z_step = None;

    let mut seen_x: HashMap<Vec<(i64, i64)>, usize> = HashMap::new();
    let mut seen_y: HashMap<Vec<(i64, i64)>, usize> = HashMap::new();
    let mut seen_z: HashMap<Vec<(i64, i64)>, usize> = HashMap::new();

    let mut steps = 0;
    while x_step.is_none() || y_step.is_none() || z_step.is_none() {
        if x_step.is_none() {
            let moons_x = moons.iter().map(|moon| (moon.position.0, moon.velocity.0)).collect();
            if seen_x.insert(moons_x, steps).is_some() {
                x_step = Some(steps);
            }
        }

        if y_step.is_none() {
            let moons_y = moons.iter().map(|moon| (moon.position.1, moon.velocity.1)).collect();
            if seen_y.insert(moons_y, steps).is_some() {
                y_step = Some(steps);
            }
        }

        if z_step.is_none() {
            let moons_z = moons.iter().map(|moon| (moon.position.2, moon.velocity.2)).collect();
            if seen_z.insert(moons_z, steps).is_some() {
                z_step = Some(steps);
            }
        }

        simulate_step(moons);
        steps += 1;
    }

    let (x, y, z) = (x_step.unwrap(), y_step.unwrap(), z_step.unwrap());

    // Probably a much better way of doing this but it works...
    let &largest = [x, y, z].iter().max().unwrap();
    let mut i = largest;
    while i % x != 0 || i % y != 0 || i % z != 0 {
        i += largest;
    }

    i
}

fn calculate_energy(moons: &[Moon]) -> i64 {
    moons.iter()
        .map(|moon| {
            (moon.position.0.abs() + moon.position.1.abs() + moon.position.2.abs()) *
            (moon.velocity.0.abs() + moon.velocity.1.abs() + moon.velocity.2.abs())
        })
        .sum()
}

fn main() {
    let initial_moons = init_moons(&[
        (5, 4, 4),
        (-11, -11, -3),
        (0, 7, 0),
        (-13, 2, 10),
    ]);

    // Part 1
    let mut moons = initial_moons.clone();
    for _ in 0..1000 {
        simulate_step(&mut moons);
    }
    println!("Total energy: {}", calculate_energy(&moons));

    // Part 2
    let mut moons = initial_moons.clone();
    println!("Repeating step: {:?}", find_repeating_step(&mut moons));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_case_1() {
        let mut moons = init_moons(&[
            (-1, 0, 2),
            (2, -10, -7),
            (4, -8, 8),
            (3, 5, -1),
        ]);

        for _ in 0..10 {
            simulate_step(&mut moons);
        }

        assert_eq!(moons, vec![
            Moon { position: (2, 1, -3), velocity: (-3, -2, 1) },
            Moon { position: (1, -8, 0), velocity: (-1, 1, 3) },
            Moon { position: (3, -6, 1), velocity: (3, 2, -3) },
            Moon { position: (2, 0, 4), velocity: (1, -1, -1) },
        ]);

        assert_eq!(calculate_energy(&moons), 179);
    }

    #[test]
    fn test_case_2() {
        let mut moons = init_moons(&[
            (-8, -10, 0),
            (5, 5, 10),
            (2, -7, 3),
            (9, -8, -3),
        ]);

        for _ in 0..100 {
            simulate_step(&mut moons);
        }

        assert_eq!(moons, vec![
            Moon { position: (8, -12, -9), velocity: (-7, 3, 0) },
            Moon { position: (13, 16, -3), velocity: (3, -11, -5) },
            Moon { position: (-29, -11, -1), velocity: (-3, 7, 4) },
            Moon { position: (16, -13, 23), velocity: (7, 1, 1) },
        ]);

        assert_eq!(calculate_energy(&moons), 1940);
    }
}
