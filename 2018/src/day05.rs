use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;

#[derive(Debug, PartialEq)]
struct Polymer(Vec<Atom>);

#[derive(Debug, PartialEq, Copy, Clone)]
struct Atom {
  symbol: char,
  polarity: Polarity
}

#[derive(Debug, PartialEq, Copy, Clone)]
enum Polarity {
  Up,
  Down
}

impl Atom {
  pub fn from_char(ch: char) -> Self {
    Atom {
      symbol: ch.to_ascii_uppercase(),
      polarity: if ch.is_ascii_uppercase() { Polarity::Up } else { Polarity::Down }
    }
  }

  pub fn reacts_with(self, other: Atom) -> bool {
    self.symbol == other.symbol && self.polarity != other.polarity
  }
}

impl Polymer {
  pub fn react(&self) -> Self {
    let mut reacted: Vec<Atom> = Vec::new();

    for &atom in self.0.iter() {
      match reacted.last() {
        Some(last_atom) => {
          if last_atom.reacts_with(atom) {
            reacted.pop();
          } else {
            reacted.push(atom);
          }
        },
        None => reacted.push(atom)
      }
    }

    Polymer(reacted)
  }

  pub fn remove_symbol(&self, symbol: char) -> Self {
    Polymer(
      self.0.iter()
      .filter(|atom| atom.symbol != symbol)
      .cloned()
      .collect()
    )
  }

  pub fn len(&self) -> usize {
    self.0.len()
  }
}

impl FromStr for Polymer {
  type Err = ();

  fn from_str(s: &str) -> Result<Self, ()> {
    Ok(Polymer(
      s.chars()
        .filter(char::is_ascii_alphabetic)
        .map(Atom::from_char)
        .collect()
    ))
  }
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);

  let mut input = String::new();
  reader.read_to_string(&mut input).unwrap();

  let polymer: Polymer = input.parse().unwrap();

  println!("Length of reacted polymer: {}", polymer.react().len());
  println!("Shortest length: {}", shortest_length_once_removed(&polymer));
}

fn shortest_length_once_removed(polymer: &Polymer) -> usize {
  (b'A'..b'Z')
    .map(|symbol| polymer.remove_symbol(symbol as char).react().len())
    .min()
    .unwrap()
}

#[cfg(test)]
mod tests {
  use super::*;
  use super::Polarity::*;

  #[test]
  fn test_unit_from_char() {
    assert_eq!(
      Atom::from_char('a'),
      Atom { symbol: 'A', polarity: Down }
    );
    assert_eq!(
      Atom::from_char('B'),
      Atom { symbol: 'B', polarity: Up }
    );
  }

  #[test]
  fn test_polymer_from_str() {
    assert_eq!(
      "dabAcCaCBAcCcaDA".parse::<Polymer>().unwrap(),
      Polymer(vec![
        Atom { symbol: 'D', polarity: Down },
        Atom { symbol: 'A', polarity: Down },
        Atom { symbol: 'B', polarity: Down },
        Atom { symbol: 'A', polarity: Up },
        Atom { symbol: 'C', polarity: Down },
        Atom { symbol: 'C', polarity: Up },
        Atom { symbol: 'A', polarity: Down },
        Atom { symbol: 'C', polarity: Up },
        Atom { symbol: 'B', polarity: Up },
        Atom { symbol: 'A', polarity: Up },
        Atom { symbol: 'C', polarity: Down },
        Atom { symbol: 'C', polarity: Up },
        Atom { symbol: 'C', polarity: Down },
        Atom { symbol: 'A', polarity: Down },
        Atom { symbol: 'D', polarity: Up },
        Atom { symbol: 'A', polarity: Up }
      ])
    );
  }

  #[test]
  fn test_polymer_react() {
    let polymer: Polymer = "dabAcCaCBAcCcaDA".parse().unwrap();

    assert_eq!(
      polymer.react(),
      "dabCBAcaDA".parse().unwrap()
    );
  }

  #[test]
  fn test_polymer_remove_symbol() {
    let polymer: Polymer = "dabAcCaCBAcCcaDA".parse().unwrap();

    assert_eq!(
      polymer.remove_symbol('A'),
      "dbcCCBcCcD".parse().unwrap()
    );
    assert_eq!(
      polymer.remove_symbol('B'),
      "daAcCaCAcCcaDA".parse().unwrap()
    );
    assert_eq!(
      polymer.remove_symbol('C'),
      "dabAaBAaDA".parse().unwrap()
    );
    assert_eq!(
      polymer.remove_symbol('D'),
      "abAcCaCBAcCcaA".parse().unwrap()
    );
  }

  #[test]
  fn test_shortest_length_once_removed() {
    let polymer: Polymer = "dabAcCaCBAcCcaDA".parse().unwrap();

    assert_eq!(4, shortest_length_once_removed(&polymer));
  }
}
