use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::collections::HashMap;

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let box_ids: Vec<String> = reader.lines().flatten().collect();

  println!("Checksum: {}", get_checksum(&box_ids));
  println!(
    "Matching box ID common letters: {}",
    find_almost_equal_pair(&box_ids).unwrap()
  );
}

fn get_checksum<T: AsRef<str>>(box_ids: &[T]) -> usize {
  let mut num_containing_two = 0;
  let mut num_containing_three = 0;

  for box_id in box_ids.iter() {
    let freq = char_frequency(box_id.as_ref());

    if freq.values().any(|&count| count == 2) {
      num_containing_two += 1;
    }
    if freq.values().any(|&count| count == 3) {
      num_containing_three += 1;
    }
  }

  num_containing_two * num_containing_three
}

fn char_frequency(string: &str) -> HashMap<char, usize> {
  string.chars().fold(HashMap::new(), |mut freq, letter| {
    *freq.entry(letter).or_insert(0) += 1;
    freq
  })
}

fn find_almost_equal_pair<T: AsRef<str>>(box_ids: &[T]) -> Option<String> {
  for (index, box_id) in box_ids.iter().enumerate() {
    for other_box_id in box_ids[index+1..].iter() {
      if almost_equal(box_id.as_ref(), other_box_id.as_ref()) {
        return Some(
          box_id.as_ref().chars().zip(other_box_id.as_ref().chars())
            .filter(|(l, r)| l == r)
            .map(|(l, _)| l)
            .collect()
        );
      }
    }
  }
  None
}

fn almost_equal(left: &str, right: &str) -> bool {
  if left.len() != right.len() {
    return false;
  }

  let mut rest = left.chars().zip(right.chars())
    .skip_while(|(l, r)| l == r);

  match rest.next() {
    Some(_) => rest.all(|(l, r)| l == r),
    None => false
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_get_checksum() {
    let box_ids = &[
      "abcdef",
      "bababc",
      "abbcde",
      "abcccd",
      "aabcdd",
      "abcdee",
      "ababab"
    ];

    assert_eq!(12, get_checksum(box_ids));
  }

  #[test]
  fn test_char_frequency() {
    let freq = char_frequency("bababc");

    assert_eq!(2, freq[&'a']);
    assert_eq!(3, freq[&'b']);
    assert_eq!(1, freq[&'c']);
    assert_eq!(None, freq.get(&'d'));
  }

  #[test]
  fn test_find_almost_equal_pair() {
    let box_ids = &[
      "abcde",
      "fghij",
      "klmno",
      "pqrst",
      "fguij",
      "axcye",
      "wvxyz"
    ];

    assert_eq!(Some("fgij".to_string()), find_almost_equal_pair(box_ids));
  }

  #[test]
  fn test_almost_equal() {
    assert!(!almost_equal("abcde", "abcde"));
    assert!(!almost_equal("abcde", "axcye"));
    assert!(!almost_equal("abcde", "bcdea"));
    assert!(!almost_equal("abcde", "abcx"));
    assert!(!almost_equal("a", "a"));

    assert!(almost_equal("abcde", "xbcde"));
    assert!(almost_equal("abcde", "axcde"));
    assert!(almost_equal("abcde", "abxde"));
    assert!(almost_equal("abcde", "abcxe"));
    assert!(almost_equal("abcde", "abcdx"));
    assert!(almost_equal("fghij", "fguij"));
    assert!(almost_equal("a", "b"));
  }
}
