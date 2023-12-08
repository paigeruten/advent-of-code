use day15::{Program, VM, ExecuteStatus};
use num_enum::TryFromPrimitive;
use std::collections::HashMap;
use std::convert::TryFrom;
use std::fmt;
use std::io;

#[derive(Debug, PartialEq, Eq, Copy, Clone)]
enum Direction {
    North,
    South,
    West,
    East,
}

impl Direction {
    pub fn from_delta(delta: (i64, i64)) -> Self {
        use Direction::*;

        match delta {
            (0, -1) => North,
            (0, 1)  => South,
            (-1, 0) => West,
            (1, 0)  => East,

            _ => panic!("Invalid delta"),
        }
    }

    pub fn code(self) -> i64 {
        use Direction::*;

        match self {
            North => 1,
            South => 2,
            West  => 3,
            East  => 4,
        }
    }

    pub fn delta(self) -> (i64, i64) {
        use Direction::*;

        match self {
            North => (0, -1),
            South => (0, 1),
            West  => (-1, 0),
            East  => (1, 0),
        }
    }

    pub fn move_from(self, x: i64, y: i64) -> (i64, i64) {
        let (dx, dy) = self.delta();
        (x + dx, y + dy)
    }
}

#[derive(Debug, TryFromPrimitive, PartialEq, Eq, Copy, Clone)]
#[repr(u8)]
enum Tile {
    Wall = 0,
    Empty = 1,
    OxygenSystem = 2,
    Unexplored = 3,
    You = 4,
    Path = 5,
    Oxygen = 6,
    OxygenVanguard = 7,
}

impl Tile {
    pub fn color(self) -> image::Rgb<u8> {
        use Tile::*;

        match self {
            Wall         => image::Rgb([128, 128, 128]),
            Empty        => image::Rgb([255, 255, 255]),
            OxygenSystem => image::Rgb([0, 200, 0]),
            Unexplored   => image::Rgb([0, 0, 0]),
            You          => image::Rgb([200, 0, 0]),
            Path         => image::Rgb([255, 200, 150]),
            Oxygen       => image::Rgb([150, 150, 255]),
            OxygenVanguard => image::Rgb([0, 0, 200]),
        }
    }
}

impl fmt::Display for Tile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        use Tile::*;

        match self {
            Wall         => write!(f, "#"),
            Empty        => write!(f, "."),
            OxygenSystem => write!(f, "*"),
            Unexplored   => write!(f, " "),
            You          => write!(f, "@"),
            Path         => write!(f, ","),
            Oxygen       => write!(f, "~"),
            OxygenVanguard => write!(f, "~"),
        }
    }
}

#[derive(Debug)]
struct World {
    x: i64,
    y: i64,
    tiles: HashMap<(i64, i64), Tile>,
    visualize: bool,
}

impl World {
    pub fn new() -> Self {
        let mut tiles = HashMap::new();
        tiles.insert((0, 0), Tile::Empty);

        World { x: 0, y: 0, tiles, visualize: false }
    }

    pub fn unexplored_direction(&self) -> Option<Direction> {
        use Direction::*;

        [North, West, South, East].into_iter().find(|dir| {
            let pos = dir.move_from(self.x, self.y);
            return !self.tiles.contains_key(&pos);
        }).cloned()
    }

    pub fn render_image(&self, path: &[(i64, i64)], oxygens: &[(i64, i64)], filename: &str) {
        if !self.visualize { return; }

        let min_x = self.tiles.keys().map(|&(x, _)| x).min().unwrap();
        let max_x = self.tiles.keys().map(|&(x, _)| x).max().unwrap();
        let min_y = self.tiles.keys().map(|&(_, y)| y).min().unwrap();
        let max_y = self.tiles.keys().map(|&(_, y)| y).max().unwrap();

        const TILE_SIZE: u32 = 24;

        let mut imgbuf = image::ImageBuffer::new(41 * TILE_SIZE, 41 * TILE_SIZE);

        for pixel in imgbuf.pixels_mut() {
            *pixel = image::Rgb([0, 0, 0]);
        }

        let mut abs_y = 0;
        for y in min_y..=max_y {
            let mut abs_x = 0;
            for x in min_x..=max_x {
                let color = if x == self.x && y == self.y {
                    &Tile::You
                } else if path.iter().any(|&(px, py)| x == px && y == py) {
                    &Tile::Path
                } else if oxygens.iter().any(|&(ox, oy)| x == ox && y == oy) {
                    &Tile::OxygenVanguard
                } else {
                    self.tiles.get(&(x, y))
                        .unwrap_or(&Tile::Unexplored)
                }.color();

                for img_y in abs_y*TILE_SIZE..abs_y*TILE_SIZE+TILE_SIZE {
                    for img_x in abs_x*TILE_SIZE..abs_x*TILE_SIZE+TILE_SIZE {
                        imgbuf.put_pixel(img_x, img_y, color);
                    }
                }

                abs_x += 1;
            }
            abs_y += 1;
        }

        imgbuf.save(filename).unwrap();
    }
}

impl fmt::Display for World {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let min_x = self.tiles.keys().map(|&(x, _)| x).min().unwrap();
        let max_x = self.tiles.keys().map(|&(x, _)| x).max().unwrap();
        let min_y = self.tiles.keys().map(|&(_, y)| y).min().unwrap();
        let max_y = self.tiles.keys().map(|&(_, y)| y).max().unwrap();

        for y in min_y..=max_y {
            for x in min_x..=max_x {
                let tile = if x == self.x && y == self.y {
                    &Tile::You
                } else {
                    self.tiles.get(&(x, y))
                        .unwrap_or(&Tile::Unexplored)
                };

                write!(f, "{}", tile)?;
            }
            writeln!(f)?;
        }

        Ok(())
    }
}

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let program = line.parse::<Program>().unwrap();

    let mut vm = VM::new(&program);

    let mut world = World::new();
    world.visualize = true;

    let mut path = vec![(0, 0)];

    let mut oxygen_system_pos = None;

    let mut frame = 0;
    loop {
        world.render_image(&path, &[], &format!("vis/{:05}.png", frame));

        if let Some(direction) = world.unexplored_direction() {
            let (nx, ny) = direction.move_from(world.x, world.y);

            assert_eq!(vm.execute(), ExecuteStatus::NeedInput);
            vm.send_input(direction.code());
            assert_eq!(vm.execute(), ExecuteStatus::Output);

            let tile = Tile::try_from(vm.recv_output() as u8)
                .expect("Invalid tile code");

            if tile != Tile::Wall {
                world.x = nx;
                world.y = ny;
                path.push((nx, ny));
            }

            if tile == Tile::OxygenSystem {
                oxygen_system_pos = Some((nx, ny));
                println!("Path length to oxygen system: {}", path.len() - 1);
            }

            world.tiles.insert((nx, ny), tile);
        } else {
            path.pop();
            if let Some(&(nx, ny)) = path.last() {
                let direction = Direction::from_delta((nx - world.x, ny - world.y));

                assert_eq!(vm.execute(), ExecuteStatus::NeedInput);
                vm.send_input(direction.code());
                assert_eq!(vm.execute(), ExecuteStatus::Output);
                vm.recv_output();

                world.x = nx;
                world.y = ny;
            } else {
                break;
            }
        }

        frame += 1;
    }

    // Delay video...
    for _ in 0..60 {
        world.render_image(&path, &[], &format!("vis/{:05}.png", frame));
        frame += 1;
    }

    let mut oxygens = vec![oxygen_system_pos.unwrap()];

    let mut minutes = 0;
    while !oxygens.is_empty() {
        let mut new_oxygens = vec![];

        for (ox, oy) in oxygens.into_iter() {
            use Direction::*;
            for dir in &[North, South, West, East] {
                let (nx, ny) = dir.move_from(ox, oy);
                if world.tiles.get(&(nx, ny)) == Some(&Tile::Empty) {
                    world.tiles.insert((nx, ny), Tile::Oxygen);
                    new_oxygens.push((nx, ny));
                }
            }
        }

        oxygens = new_oxygens;

        // Half speed for video...
        for _ in 0..2 {
            world.render_image(&[], &oxygens, &format!("vis/{:05}.png", frame));
            frame += 1;
        }

        minutes += 1;
    }

    // Delay video...
    for _ in 0..150 {
        world.render_image(&[], &oxygens, &format!("vis/{:05}.png", frame));
        frame += 1;
    }

    println!("It took {} minutes for the oxygen to fully spread.", minutes - 1);
}
