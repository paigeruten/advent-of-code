use std::fmt;
use std::io;
use std::str::FromStr;

const WIDTH: usize = 25;
const HEIGHT: usize = 6;

#[derive(Debug)]
struct Image {
    layers: Vec<Layer>,
}

impl Image {
    pub fn new(layers: Vec<Layer>) -> Option<Self> {
        if layers.is_empty() { return None }

        let len = layers[0].len();
        if layers.iter().any(|layer| layer.len() != len) {
            return None;
        }

        Some(Image { layers })
    }

    pub fn layer_with_fewest_zeros(&self) -> Option<&Layer> {
        self.layers.iter()
            .min_by_key(|layer| layer.count(0))
    }

    pub fn flatten(&self) -> Layer {
        let mut flattened = Layer::empty();

        for layer in self.layers.iter() {
            flattened.add(layer);
        }

        flattened
    }
}

impl FromStr for Image {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let all_pixels: Vec<u8> = s.chars()
            .filter_map(|c| c.to_digit(10).map(|d| d as u8))
            .collect();

        let layers = all_pixels
            .chunks(WIDTH * HEIGHT)
            .map(|chunk| Layer::new(chunk.to_vec()))
            .collect();

        Image::new(layers).ok_or(())
    }
}

#[derive(Debug, Clone)]
struct Layer {
    pixels: Vec<u8>,
}

impl Layer {
    pub fn new(pixels: Vec<u8>) -> Self {
        Layer { pixels }
    }

    pub fn empty() -> Self {
        Layer { pixels: vec![2; WIDTH * HEIGHT] }
    }

    pub fn len(&self) -> usize {
        self.pixels.len()
    }

    pub fn count(&self, pixel: u8) -> usize {
        self.pixels.iter()
            .filter(|&&p| p == pixel)
            .count()
    }

    pub fn add(&mut self, other: &Layer) {
        for i in 0..self.pixels.len() {
            if self.pixels[i] == 2 {
                self.pixels[i] = other.pixels[i];
            }
        }
    }
}

impl fmt::Display for Layer {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        for y in 0..HEIGHT {
            for x in 0..WIDTH {
                match self.pixels[y * WIDTH + x] {
                    0 => write!(f, " ")?,
                    1 => write!(f, "#")?,
                    2 => write!(f, "!")?,
                    _ => write!(f, "?")?,
                }
            }
            writeln!(f)?;
        }
        Ok(())
    }
}

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).unwrap();
    let image: Image = line.parse().unwrap();

    let layer = image.layer_with_fewest_zeros().unwrap();
    let checksum = layer.count(1) * layer.count(2);

    println!("Checksum: {}", checksum);
    println!();

    let flattened = image.flatten();
    println!("{}", flattened);
}

