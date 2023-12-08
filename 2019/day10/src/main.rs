use std::collections::HashMap;
use std::io;
use std::io::BufRead;
use std::thread;

fn gcd(mut a: i32, mut b: i32) -> i32 {
    while a != 0 {
        let temp = a;
        a = b % a;
        b = temp;
    }
    b.abs()
}

fn in_line_of_sight(map: &Vec<Vec<char>>, x1: i32, y1: i32, x2: i32, y2: i32) -> bool {
    let dx = x2 - x1;
    let dy = y2 - y1;
    let gcd = gcd(dx, dy);
    let dx = dx / gcd;
    let dy = dy / gcd;

    let mut x = x1 + dx;
    let mut y = y1 + dy;
    while !(x == x2 && y == y2) {
        if map[y as usize][x as usize] == '#' {
            return false;
        }
        x += dx;
        y += dy;
    }

    true
}

fn print_map(map: &Vec<Vec<char>>) {
    for row in map.iter() {
        for cell in row.iter() {
            print!("{}", cell);
        }
        println!();
    }
    println!();
}

fn main() {
    let mut map: Vec<Vec<char>> = io::stdin().lock()
        .lines()
        .map(|line| line.unwrap().chars().collect())
        .collect();

    let mut asteroids: Vec<(i32, i32)> = Vec::new();
    for y in 0..map.len() {
        for x in 0..map[0].len() {
            if map[y][x] == '#' {
                asteroids.push((x as i32, y as i32));
            }
        }
    }

    let mut counts: HashMap<(i32, i32), usize> = HashMap::new();
    for &(x1, y1) in asteroids.iter() {
        for &(x2, y2) in asteroids.iter() {
            if !(y1 == y2 && x1 == x2) {
                if in_line_of_sight(&map, x1 as i32, y1 as i32, x2 as i32, y2 as i32) {
                    *counts.entry((x1 as i32, y1 as i32)).or_insert(0) += 1;
                }
            }
        }
    }

    let (&(station_x, station_y), num_in_sight) = counts.iter()
        .max_by_key(|(_, &count)| count)
        .unwrap();

    map[station_y as usize][station_x as usize] = 'X';
    let mut asteroids = asteroids.iter()
        .filter(|(x, y)| !(*x == station_x && *y == station_y))
        .collect::<Vec<_>>();

    asteroids.sort_by_key(|(x, y)| {
        let dx = (station_x - x) as f64;
        let dy = (station_y - y) as f64;
        let angle = if *x == station_x && *y < station_y {
            -1000000000
        } else {
            (dx.atan2(-dy) * 1000000.) as i64
        };
        (
            angle,
            (station_x - x).abs() + (station_y - y).abs(),
        )
    });

    let mut asteroids_demolished = 0;
    'outer: loop {
        let mut asteroids_exist = false;
        let mut last_dx = std::i32::MAX;
        let mut last_dy = std::i32::MAX;
        for (x, y) in asteroids.iter() {
            if map[*y as usize][*x as usize] != '#' {
                continue;
            }
            asteroids_exist = true;

            let dx = station_x - x;
            let dy = station_y - y;
            let gcd = gcd(dx, dy);
            let dx = dx / gcd;
            let dy = dy / gcd;

            if !(dx == last_dx && dy == last_dy) {
                map[*y as usize][*x as usize] = '~';
                asteroids_demolished += 1;
                print_map(&map);

                if asteroids_demolished == 200 {
                    println!("200th asteroid vaporized: ({}, {})", x, y);
                    break 'outer;
                }
            }

            last_dx = dx;
            last_dy = dy;

            thread::sleep_ms(20);
        }

        if !asteroids_exist {
            break;
        }
    }

    println!("Asteroids in sight from station: {}", num_in_sight);

}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_gcd() {
        assert_eq!(gcd(9, 27), 9);
        assert_eq!(gcd(25, 30), 5);
        assert_eq!(gcd(4, 4), 4);
        assert_eq!(gcd(1, 4), 1);
        assert_eq!(gcd(-9, 27), 9);
        assert_eq!(gcd(25, -30), 5);
        assert_eq!(gcd(-4, 4), 4);
        assert_eq!(gcd(1, -4), 1);
        assert_eq!(gcd(-9, -27), 9);
        assert_eq!(gcd(-25, -30), 5);
        assert_eq!(gcd(-4, -4), 4);
        assert_eq!(gcd(-1, -4), 1);
    }
}
