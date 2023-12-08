use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::str::FromStr;

#[derive(Debug, PartialEq)]
struct Node {
  metadata: Vec<i32>,
  children: Vec<Node>,
}

impl Node {
  pub fn from_ints(ints: &[i32]) -> Result<Node, &'static str> {
    let (node, unconsumed) = Node::from_ints_aux(ints)?;

    if !unconsumed.is_empty() {
      return Err("excess data");
    }

    Ok(node)
  }

  pub fn from_ints_aux(ints: &[i32]) -> Result<(Node, &[i32]), &'static str> {
    let num_children = *ints.get(0).ok_or("expected num children")? as usize;
    let num_metadata = *ints.get(1).ok_or("expected num metadata")? as usize;
    let mut ints = &ints[2..];

    let mut children = Vec::new();

    for _ in 0..num_children {
      let (child, rest_ints) = Node::from_ints_aux(ints)?;
      ints = rest_ints;

      children.push(child);
    }

    if ints.len() < num_metadata {
      return Err("expected metadata");
    }

    let node = Node {
      children,
      metadata: ints[..num_metadata].to_vec(),
    };

    Ok((node, &ints[num_metadata..]))
  }

  pub fn metadata_sum(&self) -> i32 {
    let self_sum: i32 = self.metadata.iter().sum();
    let children_sum: i32 = self.children.iter()
      .map(Node::metadata_sum)
      .sum();

    self_sum + children_sum
  }

  pub fn value(&self) -> i32 {
    if self.children.is_empty() {
      self.metadata.iter().sum()
    } else {
      self.metadata.iter()
        .filter_map(|&index| self.children.get(index as usize - 1))
        .map(Node::value)
        .sum()
    }
  }
}

impl FromStr for Node {
  type Err = &'static str;

  fn from_str(string: &str) -> Result<Node, Self::Err> {
    string.split_whitespace()
      .map(i32::from_str)
      .collect::<Result<Vec<_>, _>>()
      .map_err(|_| "string contains invalid numbers")
      .and_then(|ints| Node::from_ints(&ints))
  }
}

pub fn solve(input_file: File) {
  let mut reader = BufReader::new(input_file);

  let mut input = String::new();
  reader.read_to_string(&mut input).unwrap();

  let tree: Node = input.parse().unwrap();

  println!("Sum of metadata: {}", tree.metadata_sum());
  println!("Value of tree: {}", tree.value());
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn node_from_ints() {
    let tree = Node::from_ints(&[2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]).unwrap();

    assert_eq!(
      tree,
      Node {
        metadata: vec![1, 1, 2],
        children: vec![
          Node {
            metadata: vec![10, 11, 12],
            children: vec![]
          },
          Node {
            metadata: vec![2],
            children: vec![
              Node {
                metadata: vec![99],
                children: vec![]
              }
            ]
          }
        ]
      }
    );
  }

  #[test]
  fn node_from_ints_excess_data() {
    let result = Node::from_ints(&[2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2, 1]);

    assert_eq!(result, Err("excess data"));
  }

  #[test]
  fn node_from_ints_missing_num_children() {
    let result = Node::from_ints(&[2, 3, 0, 3, 10, 11, 12]);

    assert_eq!(result, Err("expected num children"));
  }

  #[test]
  fn node_from_ints_missing_num_metadata() {
    let result = Node::from_ints(&[2, 3, 0, 3, 10, 11, 12, 1]);

    assert_eq!(result, Err("expected num metadata"));
  }

  #[test]
  fn node_from_ints_missing_metadata() {
    let result = Node::from_ints(&[2, 3, 0, 3, 10, 11]);

    assert_eq!(result, Err("expected metadata"));
  }

  #[test]
  fn node_from_ints_no_data() {
    let result = Node::from_ints(&[]);

    assert_eq!(result, Err("expected num children"));
  }

  #[test]
  fn node_parse() {
    let tree: Node = "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2".parse().unwrap();

    assert_eq!(
      tree,
      Node {
        metadata: vec![1, 1, 2],
        children: vec![
          Node {
            metadata: vec![10, 11, 12],
            children: vec![]
          },
          Node {
            metadata: vec![2],
            children: vec![
              Node {
                metadata: vec![99],
                children: vec![]
              }
            ]
          }
        ]
      }
    );
  }

  #[test]
  fn node_parse_invalid_numbers() {
    let result = "2 3 0 a b c".parse::<Node>();

    assert_eq!(result, Err("string contains invalid numbers"));
  }

  #[test]
  fn node_metadata_sum() {
    let tree = Node::from_ints(&[2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]).unwrap();

    assert_eq!(tree.metadata_sum(), 138);
  }

  #[test]
  fn node_value() {
    let tree = Node::from_ints(&[2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]).unwrap();

    assert_eq!(tree.value(), 66);
  }
}

