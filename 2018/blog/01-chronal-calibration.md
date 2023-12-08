# Day 1: Chronal Calibration

The last couple years of [Advent of Code](https://adventofcode.com/) I focused on solving the puzzles as fast as possible, to try and get on the leaderboard. To do that, I had to show up at 11pm every single night to start solving the puzzle as soon as it's released. And I had to use [Ruby](https://www.ruby-lang.org/), the only language I'm comfortable enough with to be fast.

This year I just want to relax and learn [Rust](https://www.rust-lang.org/). I'm going to take my time with the puzzles and focus on writing good Rust code. I'm also going to try to blog about everything I learn as I solve the puzzles, mostly just to practice blogging.

## Part 1

The first challenge has you apply a large list of positive and negative frequency changes to a device that starts out with an initial frequency of 0.

In other words: Add up a list of integers and print the sum.

I immediately feel the need to write a one-liner in Ruby:

```ruby
p readlines.map(&:to_i).sum
```

Ruby is such a good language to [think in](http://poignant.guide/book/chapter-3.html):

> But what do you call the language when your brain begins to think in that language? When you start to use the language’s own words and colloquialisms to express yourself. Say, the computer can’t do that. How can it be the computer’s language? It is ours, we speak it natively!

Now how do I translate that one-liner into Rust? There are 4 things I need to learn: (1) How to set up a Rust project, (2) How to read lines from a text file, (3) How to convert strings to integers, and (4) How to sum up the list of integers in the most idiomatic way (does Rust have `.sum()`?).

### Rust setup

The [Rust Book](https://doc.rust-lang.org/book) is what I'll use to learn the basics of Rust.

The [Installation](https://doc.rust-lang.org/book/2018-edition/ch01-01-installation.html) section explains how to install Rust. I've tried out Rust before, so I already have [rustup](https://rustup.rs/). All I need to do is run `rustup update` to make sure I've got the latest Rust.

I could make the solution for each day a separate standalone Rust program, but I want to learn how to build a large Rust program that's organized into modules. I also might want to be able to easily share code between the solutions, to at least cut down on the boilerplate of reading the input file.

`cargo` is Rust's package management tool, which also helps you build, run, and test your own binary package. The [Hello, Cargo!](https://doc.rust-lang.org/book/2018-edition/ch01-03-hello-cargo.html) section explains how to use it. `cargo new aoc` creates an `aoc` (Advent Of Code) folder with a brand new binary project (as opposed to library project). You start out with basically two files: `Cargo.toml` for declaring your dependencies, and `src/main.rs` where you put your `main()` function.

`cargo build` builds the project. `cargo run` runs the executable (building it first if needed).

`cargo check` is interesting: it checks whether your program compiles successfully without actually building it. It's faster than `cargo build` and it's nice to be able to run it early and often as you're coding to get those really helpful Rust error messages (["pair programming is sorta built directly into the language" - @ag_dubs](https://twitter.com/ag_dubs/status/1008016418657353728)).

### Reading lines from a file

I found an example of how to read a file line by line in the Rust docs for [std::io (Iterator types)](https://doc.rust-lang.org/std/io/index.html#iterator-types):

```rust
use std::io;
use std::io::prelude::*;
use std::io::BufReader;
use std::fs::File;

fn main() -> io::Result<()> {
  let file = File::open("input/input01")?;
  let reader = BufReader::new(file);

  for line in reader.lines() {
    println!("{}", line?);
  }
  Ok(())
}
```

The `?` is a new development since I last tried learning Rust. In the `let file = ...` line, the `?` at the end is syntax sugar for:

```rust
let file = match File::open("input/input01") {
  Ok(file) => file,
  error => return error;
};
```

So when `File::open()` returns an error, we will immediately return the error from the `main()` function. Otherwise we'll assign the unwrapped return value to `file`. This is such a common pattern for error handling in Rust that they added a `?` operator to take care of it for you.

I guess the `main()` function returning a `Result` is similar to returning an integer from `main()` in a C program. If you return an `Ok`, it exits with a `0` exit status, and if you return an `Err`, it prints the error and exits with a `1` exit status.

### Reading command line arguments

At this point, I'd like to have the input file passed as a command line argument, instead of hard-coding it into the program.

[`env::args()`](https://doc.rust-lang.org/std/env/fn.args.html) returns an iterator over the command line arguments, which we can convert to a vector of strings using `collect()`.

```rust
let args: Vec<String> = env::args().collect();

let file = File::open(&args[1])?;
```

When using `collect()`, you usually have to specify the type that it returns (`Vec<String>` in this case). This is because there are multiple types that `collect()` can return (`VecDeque<String>` for example).

If `args[1]` doesn't exist (i.e. no command line arguments were passed), we'll get a runtime bounds-checking error. That's good enough for now, we'll add proper error handling later.

### Parsing strings to integers

After a lot of Googling and looking through the Rust docs, I figured out that [`str.parse()`](https://doc.rust-lang.org/std/primitive.str.html#method.parse) seems to be the standard way of converting a string to an integer. It parses anything that implements the `FromStr` trait. So I guess `"123".parse::<i32>()` is [equivalent](https://doc.rust-lang.org/src/core/str/mod.rs.html#3954-3956) to `i32::from_str("123")`.

```rust
for line in reader.lines() {
  let freq: i32 = line?.parse().unwrap();
  println!("{}", freq);
}
```

Just like with `collect()`, we have to specify the exact integer type we want to convert the string to. `.unwrap()` is a quick 'n' easy way of handling errors: it causes the program to panic if the string failed to parse to an integer.

### Adding up the frequency changes

Yay, I think I can do the rest without Googling! We just need a mutable variable to keep track of the total sum, and print it out at the end.

```rust
let mut freq = 0;

for line in reader.lines() {
  freq += line?.parse::<i32>().unwrap();
}

println!("Resulting frequency: {}", freq);
```

Here I had to use the "turbofish" operator `::<>` to specify the return value of `parse()`. Even if I declared `freq` to be an `i32`, that isn't enough for Rust to infer that the right-hand-side of `freq += ...` should be an `i32`.

Anyways, this solved part 1, and got me my first gold star!

### Refactoring to use iterators

One thing I love about Rust is it brings functional programming patterns to the world of systems programming. I'm talking about iterators, and chaining together maps, filters, and folds. It turns out Rust even has a `sum()` method for iterators.

I want to replace that `for` loop with a couple of `map()` and `sum()` operations. Here's what I came up with:

```rust
let freq_changes: Vec<i32> = reader.lines().map(|line|
  line.unwrap().parse().unwrap()
).collect();

let freq: i32 = freq_changes.iter().sum();

println!("Resulting frequency: {}", freq);
```

This does have the disadvantage of reading all the numbers into memory before summing them together, whereas before we were only reading one number at a time and throwing it away before reading the next one. But I took a peek at part 2 of today's puzzle, and it looks like we'll need to store all the numbers in a `Vec` anyways to solve part 2.

## Part 2

For this part, we need to *remember* every intermediate sum as we go through the list, and we need to be able to start back from the beginning of the list when we reach the end. As soon as we hit an intermediate sum that we've seen before, that number is the solution.

The first thing we'll do is clean up the code a bit by moving the code that's specific to part 1 to its own function, and creating a new function for the code that's specific to part 2. Converting the input file into a `Vec` of integers is common to both parts, and will be shared in `main()`.

```rust
fn main() -> io::Result<()> {
  let args: Vec<String> = env::args().collect();

  let file = File::open(&args[1])?;
  let reader = BufReader::new(file);

  let freq_changes: Vec<i32> = reader.lines().map(|line|
    line.unwrap().parse().unwrap()
  ).collect();

  println!(
    "Resulting frequency: {}",
    resulting_frequency(&freq_changes)
  );
  println!(
    "First frequency reached twice: {}",
    first_frequency_reached_twice(&freq_changes)
  );
  Ok(())
}

fn resulting_frequency(freq_changes: &[i32]) -> i32 {
  freq_changes.iter().sum()
}

fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  0
}
```

We're passing a borrowed immutable slice of our `Vec` to the functions. A slice type looks like `&[i32]`, and I believe it consists of basically a pointer and a length (number of items), like a subarray.

### Tests

Now that we have our solution code in nice little functions separate from our file I/O code, it seems like a good time to write some tests! The puzzle description provides a few simple test cases we can use. I love how easy Rust makes it to write tests, you just stick them in a module at the end of the file!

```rust
#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_resulting_frequency() {
    assert_eq!(3, resulting_frequency(&[1, -2, 3, 1]));
    assert_eq!(3, resulting_frequency(&[1, 1, 1]));
    assert_eq!(0, resulting_frequency(&[1, 1, -2]));
    assert_eq!(-6, resulting_frequency(&[-1, -2, -3]));
  }

  #[test]
  fn test_first_frequency_reached_twice() {
    assert_eq!(2, first_frequency_reached_twice(&[1, -2, 3, 1]));
    assert_eq!(0, first_frequency_reached_twice(&[1, -1]));
    assert_eq!(10, first_frequency_reached_twice(&[3, 3, 4, -2, -4]));
    assert_eq!(5, first_frequency_reached_twice(&[-6, 3, 8, 5, -6]));
    assert_eq!(14, first_frequency_reached_twice(&[7, 7, -2, -7, -4]));
  }
}
```

The `#[...]` things are called [attributes](https://doc.rust-lang.org/reference/attributes.html). A module used for testing needs to be marked with `#[cfg(test)]`, and then each test function with `#[test]`. Then, all tests can be run with `cargo test`.

These test cases are all straight from the puzzle description. The `resulting_frequency()` tests all pass, but of course the `first_frequency_reached_twice()` ones do not.

### Cycling the list

Somehow I know about Rust's `cycle()` iterator function and I've been really excited to use it since reading the puzzle description for part 2. It takes an iterator and attaches the end back to the beginning so that you get an iterator that just keeps looping through the list forever.

```rust
for change in freq_changes.iter().cycle() {
  println!("{}", change);
}
```

This prints out the list of input numbers over and over and over till you press Ctrl+C.

### Keeping a running total

We need to keep a running total of frequency changes. We basically did this in part 1.

```rust
let mut freq = 0;
for change in freq_changes.iter().cycle() {
  freq += change;
  println!("{}", freq);
}
```

### Remembering seen values

Now we just need to stop the loop when we get to a frequency that we've already seen before. A set is a great data structure to use to answer the question "have I seen this before?". Rust has `HashSet` and `BTreeSet`, which are implemented in terms of `HashMap` and `BTreeMap` respectively.

The [`std::collections` docs](https://doc.rust-lang.org/std/collections/index.html) have a great summary of when to use different data structures, and different implementations of a particular data structure. `HashSet` appears to be the one to use unless you need the specific capabilities of `BTreeSet`, which have to do with sorted keys (getting the smallest/largest key, getting a range of entries, etc.).

```rust
fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  let mut seen = HashSet::new();
  let mut freq = 0;
  for change in freq_changes.iter().cycle() {
    seen.insert(freq);
    freq += change;
    if seen.contains(&freq) {
      return freq;
    }
  }
  0
}
```

Yay, this got me my 2nd gold star!

### Refactoring to use more iterators

Just for fun, I want to try and see if I can refactor this `for` loop into a chain of iterators, like I did in part 1. Of course, this will be much more challenging...

After scouring the Rust docs and a lot of fiddling around, here's my first attempt:

```rust
fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  let mut seen = HashSet::new();

  freq_changes.iter()
    .cycle()
    .scan(0, |freq, &change| {
      *freq += change;
      Some(*freq)
    })
    .take_while(|&freq| seen.insert(freq))
    .last()
    .unwrap()
}
```

That `scan()` is a really ugly way of turning a stream of integers into a stream of running totals for those integers. I wish there was a function like `scan()` that let you write `scan(0, |freq, change| freq + change)`. Like a `fold()` that returns an iterator yielding all the intermediate values instead of returning the final value. Unfortunately no such function exists, and we only have `scan()`, which is very general and yields a mutable value of your choosing (`freq` here) that you have to mutate (`*freq += change`) and then lets you return any value you like (or no value).

Anyways. So `scan()` gives us an iterator over all the intermediate sums. The `take_while` then loops over these, inserts each one into the set, and stops when `insert()` returns false. `insert()` returns false when the value it's inserting already exists, by the way. So when it stops, we then just take the `last()` item and that's the solution, right?

As it turns out, this always returns the item that comes right before the actual solution. `take_while()` returns all the items up to the one whose predicate returns false, but doesn't include that one item. Which makes sense. If you have `[1, 4, 3, -5, 7, -4, -3].take_while(|x| x > 0)` you expect it to return only numbers that are positive, not the one that made the predicate false. Oops.

There doesn't seem to be any way to tweak this code to allow me to access the item that `take_while()` excluded (the solution!), without getting rid of `take_while()` and taking a new approach. This was kind of upsetting, cause I thought for sure `take_while()` sounded like the perfect thing to use and I really wanted it to work.

But then I realized it's completely the wrong tool for the job. What I'm really looking for is `find()`:

```rust
fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  let mut seen = HashSet::new();

  freq_changes.iter()
    .cycle()
    .scan(0, |freq, &change| {
      *freq += change;
      Some(*freq)
    })
    .find(|&freq| !seen.insert(freq))
    .unwrap()
}
```

This loops through the intermediate sums, inserting each one into the set, and returning the one that `insert()` sees is already in the set when it goes to insert it. Much better!

It's a little unconventional maybe to have a predicate function perform a side effect (inserting into a set). Not very functional maybe. But the code is so *succinct*, and it makes me happy. :)

There's one little bug though. The `[1, -1]` test case is failing. It's supposed to return `0` but returns `1`. This is because the frequency is supposed to start at `0`, which means when we go through the list once and go back to `0`, that's supposed to be the second time `0` is seen and so `0` should be returned.

So we need to insert `0` into the set at the beginning. We could call `seen.insert(0);` right after creating the set. But the Rubyist in me wants to pass the initial contents of the set to the constructor, as in `Set.new([0])` or even `Set[0]`. In Rust, this turned out to be... a struggle. Which is fine, I guess it reflects the cost of allocating the array that you're passing to the constructor.

Here's my final solution for part 2:

```rust
fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  let mut seen: HashSet<i32> = HashSet::from_iter(vec![0]);

  freq_changes.iter()
    .cycle()
    .scan(0, |freq, &change| {
      *freq += change;
      Some(*freq)
    })
    .find(|&freq| !seen.insert(freq))
    .unwrap()
}
```

It's probably harder to read and less maintainable than the `for` loop solution, but I had a lot of fun and learned a lot building this chain of iterators! I never thought I'd be writing code like this in a systems language!

## Splitting the code into modules

To make way for solutions to future puzzles in this Rust project, I moved all the code for solving day 1 into `day01.rs`, and I added some code to `main()` that lets you pass a day number to the program and it'll run the solution for that day's puzzle.

Here's the final, complete state of the code for day 1:

```rust
// main.rs
use std::env;
use std::io;
use std::fs::File;
use std::process;

mod day01;

fn main() -> io::Result<()> {
  let args: Vec<String> = env::args().collect();

  if args.len() < 2 || args.len() > 3 {
    println!("Usage: {} <day number> [input file]", &args[0]);
    process::exit(1);
  }

  let day_number: u8 = args[1].parse()
    .expect("first argument must be a number");

  let file = match args.len() {
    3 => File::open(&args[2]),
    _ => File::open(format!("input/input{:02}", day_number))
  }.expect("input file doesn't exist");

  match day_number {
    1 => day01::solve(file),
    _ => panic!("Day {} not implemented yet", day_number)
  };

  Ok(())
}
```

```rust
// day01.rs
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;
use std::collections::HashSet;
use std::iter::FromIterator;

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let freq_changes: Vec<i32> = reader.lines().map(|line|
    line.unwrap().parse().unwrap()
  ).collect();

  println!(
    "Resulting frequency: {}",
    resulting_frequency(&freq_changes)
  );
  println!(
    "First frequency reached twice: {}",
    first_frequency_reached_twice(&freq_changes)
  );
}

fn resulting_frequency(freq_changes: &[i32]) -> i32 {
  freq_changes.iter().sum()
}

fn first_frequency_reached_twice(freq_changes: &[i32]) -> i32 {
  let mut seen: HashSet<i32> = HashSet::from_iter(vec![0]);

  freq_changes.iter()
    .cycle()
    .scan(0, |freq, &change| {
      *freq += change;
      Some(*freq)
    })
    .find(|&freq| !seen.insert(freq))
    .unwrap()
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_resulting_frequency() {
    assert_eq!(3, resulting_frequency(&[1, -2, 3, 1]));
    assert_eq!(3, resulting_frequency(&[1, 1, 1]));
    assert_eq!(0, resulting_frequency(&[1, 1, -2]));
    assert_eq!(-6, resulting_frequency(&[-1, -2, -3]));
  }

  #[test]
  fn test_first_frequency_reached_twice() {
    assert_eq!(2, first_frequency_reached_twice(&[1, -2, 3, 1]));
    assert_eq!(0, first_frequency_reached_twice(&[1, -1]));
    assert_eq!(10, first_frequency_reached_twice(&[3, 3, 4, -2, -4]));
    assert_eq!(5, first_frequency_reached_twice(&[-6, 3, 8, 5, -6]));
    assert_eq!(14, first_frequency_reached_twice(&[7, 7, -2, -7, -4]));
  }
}
```

## Blogging plans

I wrote way too much. On day 1, I solved the puzzle while making lots of notes on everything I was learning and my whole thought process, and made lots of tiny commits to show all the little wrong turns I took. It's day 3 now, and I just finished converting all those notes and git commits into this blog post which ended up way too long (and is full of lies!).

To make this Advent of Code more sustainable, I'm going to write the blog post while actually solving the puzzle from now on. And hopefully write less.
