use regex::Regex;
use std::collections::HashMap;
use std::collections::HashSet;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;

#[derive(Debug)]
struct Worker {
  step: Option<char>,
  time_left: i32
}

impl Worker {
  pub fn new() -> Worker {
    Worker { step: None, time_left: 0 }
  }

  pub fn work(&mut self) -> Option<char> {
    if self.has_work() {
      self.time_left -= 1;
      if self.time_left == 0 {
        let done = self.step;
        self.step = None;
        return done;
      }
    }

    None
  }

  pub fn has_work(&self) -> bool {
    self.step.is_some()
  }

  pub fn start(&mut self, step: char) {
    self.step = Some(step);
    self.time_left = 61 + (step as i32) - i32::from(b'A');
  }
}

pub fn solve(input_file: File) {
  let rule_regex = Regex::new(
    r"^Step ([A-Z]) must be finished before step ([A-Z]) can begin.$"
  ).unwrap();

  let mut dependencies: HashMap<char, HashSet<char>> = HashMap::new();

  let reader = BufReader::new(input_file);
  for line in reader.lines() {
    if let Some(caps) = rule_regex.captures(&line.unwrap()) {
      let dependency: char = caps.get(1).unwrap().as_str().chars().next().unwrap();
      let step: char = caps.get(2).unwrap().as_str().chars().next().unwrap();

      dependencies.entry(step).or_default().insert(dependency);
      dependencies.entry(dependency).or_default();
    }
  }

  let (step_order, _) = simulate(1, &dependencies);
  let (_, seconds) = simulate(5, &dependencies);

  println!("Step order (1 worker): {}", step_order);
  println!("Time to complete (5 workers): {}", seconds);
}

fn simulate(num_workers: i32, dependencies: &HashMap<char, HashSet<char>>) -> (String, i32) {
  let mut workers: Vec<Worker> = (0..num_workers).map(|_| Worker::new()).collect();

  let mut todo: Vec<char> = dependencies.keys().cloned().collect();
  todo.sort();

  let mut done = String::new();
  let num_steps = todo.len();

  let mut time = 0;
  while done.len() != num_steps {
    for worker in workers.iter_mut() {
      if let Some(done_step) = worker.work() {
        done.push(done_step);
      }
    }

    for worker in workers.iter_mut() {
      if !worker.has_work() {
        let mut i = 0;
        while i < todo.len() {
          if dependencies[&todo[i]].iter().all(|&step| done.find(|x| x == step).is_some()) {
            worker.start(todo[i]);
            todo.remove(i);
            break;
          }
          i += 1;
        }
      }
    }

    time += 1;
  }

  (done, time - 1)
}
