# Day 2: Inventory Management System

## Part 1

It's nice to take the time to read the story that goes with each puzzle this year. When I try to solve these as fast as possible, I start at the bottom, looking at the puzzle input first, then the example inputs/outputs, then skimming the prose if the examples don't make the puzzle specifications clear.

Starting with the prose first and getting a good sense of where the problem we're trying to solve actually came from... is something I want to get better at as a programmer.

Though... this problem in particular seems pretty contrived. I want to find two boxes with similar IDs, and how does getting this checksum of the likely candidates help with that?

Whatever! Maybe I'll find out in part 2. All I need to know now is that I have a text file with some data, and I need to compute a checksum for that data. Let's start with some pseudocode:

```python
for each box ID:
  if box ID contains exactly two of any character:
    num_containing_two += 1
  if box ID contains exactly three of any character:
    num_containing_three += 1

print num_containing_two * num_containing_three
```

To check if a box ID contains exactly two or three of any character, we're going to need a function that counts how many of each character appears in a given box ID. So a [frequency distribution](https://en.wikipedia.org/wiki/Frequency_distribution), a `HashMap<char, usize>` that maps characters to the number of times they appear in the box ID. We can then check if the `HashMap` contains a value of `2` or `3` as our `if` conditions in the above pseudocode. I'll call this function `char_frequency()`. Let's do some [TDD](https://en.wikipedia.org/wiki/Test-driven_development) and write a test for it.

```rust
#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_char_frequency() {
    let freq = char_frequency("bababc");

    assert_eq!(2, freq.get('a'));
    assert_eq!(3, freq.get('b'));
    assert_eq!(1, freq.get('c'));
    assert_eq!(0, freq.get('d'));
  }
}
```

This produced a `cannot find function 'char_frequency' in this scope` error so I stubbed out `char_frequency()`:

```rust
fn char_frequency(string: &str) -> HashMap<char, usize> {
  let freq = HashMap::new();
  freq
}
```

...and now I had a ton of compile errors in my test function. Fixing one set would cause another set of errors to crop up. Finally, this is what I ended up with to satisfy the Rust compiler:

```rust
#[test]
fn test_char_frequency() {
  let freq = char_frequency("bababc");

  assert_eq!(Some(&2), freq.get(&'a'));
  assert_eq!(Some(&3), freq.get(&'b'));
  assert_eq!(Some(&1), freq.get(&'c'));
  assert_eq!(None, freq.get(&'d'));
}
```

So the `get()` method returns an `Option`, that makes sense. But I'm kind of annoyed that all those primitive values have to have a `&` in front of them.

OK, no more compile errors, the test just fails. Let's try and make it pass. We need to loop over the characters of the string and record each one in the `HashMap`. The [`str.chars()`](https://doc.rust-lang.org/std/primitive.str.html#method.chars) is just what we need.

```rust
fn char_frequency(string: &str) -> HashMap<char, usize> {
  let mut freq = HashMap::new();
  for letter in string.chars() {
    let count = freq.entry(letter).or_insert(0);
    *count += 1;
  }
  freq
}
```

Um... so in the `HashMap` docs, I happened across [some example code](https://doc.rust-lang.org/std/collections/struct.HashMap.html#method.entry) for exactly the problem I'm trying to solve: counting the characters in a string. `freq.entry(letter)` returns an `Entry`, which gives mutable access to a key-value pair in the `HashMap`. If the given key doesn't exist, `or_insert(0)` ensures it does by inserting `0` as the value for that key before returning the `Entry`. So in either case, all that's left to do then is increase the value by 1. (I'm surprised we don't have to write `let mut count` to mutate it?)

For fun, I tried replacing both lines with the single statement `*freq.entry(letter).or_insert(0) += 1;`, and it works! But it's probably doing too much in one line, so I'll stick with the two-line version.

Another thing I noticed in that code example was that you can apparently index into a `HashMap` using `[]`, and it returns the value itself rather than `Option`! (I can't find the docs on this, but I'm guessing it must panic when the key doesn't exist.) So now my asserts can look like this:

```rust
assert_eq!(2, freq[&'a']);
assert_eq!(3, freq[&'b']);
assert_eq!(1, freq[&'c']);
assert_eq!(None, freq.get(&'d'));
```

Much better!

Now I want to see if I can refactor `char_frequency()` to build the `HashMap` by doing a `fold()` on the `chars()` iterator, instead of using a `for` loop.

```rust
fn char_frequency(string: &str) -> HashMap<char, usize> {
  string.chars().fold(HashMap::new(), |mut freq, letter| {
    let count = freq.entry(letter).or_insert(0);
    *count += 1;
    freq
  })
}
```

I did it! I was so scared I would need to add in a whole bunch of `&`s or `&mut`s or `move`s everywhere to get `fold()` to work with a mutable accumulator and to be able to pass ownership of it out the function. But I just wrote the code without trying to add any of that in, expecting the compiler to tell me all the things I did wrong, but I was only missing one thing, which the compiler helpfully suggested: write `|mut freq, letter|` instead of `|freq, letter|`. :D

You know what? I want to go back to that single-line way of updating the count:

```rust
fn char_frequency(string: &str) -> HashMap<char, usize> {
  string.chars().fold(HashMap::new(), |mut freq, letter| {
    *freq.entry(letter).or_insert(0) += 1;
    freq
  })
}
```

OK. Onto the next function. `get_checksum()` will take an array of strings and return the checksum. Here's the test case for it, copied from the puzzle description:

```rust
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
```

And the function stub:

```rust
fn get_checksum(box_ids: &[&str]) -> usize {
  0
}
```

`&[&str]` looks weird, I don't remember seeing that in Rust code before (not that I've seen a whole lot of Rust code). It's a slice of string slices. I think it makes sense, but it makes me wonder if there's another, better way of taking an array of strings...

Anyways, time to implement that pseudocode I came up with at the beginning of all this:

```rust
fn get_checksum(box_ids: &[&str]) -> usize {
  let mut num_containing_two = 0;
  let mut num_containing_three = 0;

  for box_id in box_ids.iter() {
    let freq = char_frequency(box_id);

    if freq.values().any(|&count| count == 2) {
      num_containing_two += 1;
    }
    if freq.values().any(|&count| count == 3) {
      num_containing_three += 1;
    }
  }

  return num_containing_two * num_containing_three;
}
```

The test passes! We're close to that gold star! I kind of want to refactor this to use *another* `fold()` to generate a frequency distribution that counts how many box_id's have exactly `x` of a char (generalizing the `2` and `3` cases). But that's complicated by the fact that there can be multiple characters that appear exactly `x` times. (Sorry, I feel like this isn't very clear.) Maybe I'll see what part 2 has in store before refactoring further.

All that's left for part 1 is passing the lines of the input file to `get_checksum()`. This turned out to be a huge struggle.

First, I had to figure out how to neatly `collect()` the `lines()` into a `Vec<String>`. The problem is that each line that `lines()` yields is really a `io::Result<String>`. This is what I started with:

```rust
let box_ids: Vec<String> = reader.lines().map(|line| line.unwrap()).collect();
```

This would work, but I was sure there was a more succinct way to do this without the explicit `map()`. Something like `into_iter()`? `map_into()`? `flatten()`? While reading through the docs I saw that `collect()` can collect a bunch of `Result<T>`s into a single `Result<T>` (returning the first error if one of them is an error). But I found that you have to specify a really verbose type that way:

```rust
let box_ids = reader.lines().collect::<std::io::Result<Vec<String>>>().unwrap();
```

This seemed unacceptable to me. Then I went back to my idea of `flatten()` and realized it's just what I'm looking for:

```rust
let box_ids: Vec<String> = reader.lines().flatten().collect();
```

In this context, `flatten()` is basically equivalent to `map(|line| line.unwrap())`. Great, finally figured that out!

But then I got another error when passing `&box_ids` to `get_checksum()`. It wouldn't accept a `&Vec<String>` for a `&[&str]` argument. I had no idea how to fix this. After a lot of Googling I managed to finally [find some answers](https://users.rust-lang.org/t/vec-string-to-str/12619/10). It turns out I was probably correct in my thought earlier that there's something not quite right about a function taking `&[&str]` as an argument. Instead, a comment in that forum thread hinted that I should write my function signature like this:

```rust
fn get_checksum<T: AsRef<str>>(box_ids: &[T]) -> usize {
```

I don't fully understand this, but it works perfectly. I just had update the line where I pass `box_id` into `char_frequency()` to:

```rust
let freq = char_frequency(box_id.as_ref());
```

So I guess the type signature is saying that `box_ids` is a slice containing elements that can be converted to `&str`, and we have to do that conversion explicitly by calling `as_ref()`. OK then!

My final `solve()` method for part 1 looks like this:

```rust
pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let box_ids: Vec<String> = reader.lines().flatten().collect();

  println!("Checksum: {}", get_checksum(&box_ids));
}
```

+1 gold star!

## Part 2

Ah, now it's time to find those boxes.

So we need to find two box IDs that differ by exactly one character. Let's write a function that takes two strings and returns `true` if they are equal except for exactly 1 character. We'll call it `almost_equal()`. Here are some test cases:

```rust
#[test]
fn test_almost_equal() {
  assert!(!almost_equal("abcde", "abcde"));
  assert!(!almost_equal("abcde", "axcye"));
  assert!(!almost_equal("abcde", "bcdea"));
  assert!(!almost_equal("abcde", "abcd"));
  assert!(!almost_equal("a", "a"));

  assert!(almost_equal("abcde", "xbcde"));
  assert!(almost_equal("abcde", "axcde"));
  assert!(almost_equal("abcde", "abxde"));
  assert!(almost_equal("abcde", "abcxe"));
  assert!(almost_equal("abcde", "abcdx"));
  assert!(almost_equal("fghij", "fguij"));
  assert!(almost_equal("a", "b"));
}
```

I'm so excited to use [`zip()`](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.zip)!

```rust
fn almost_equal(left: &str, right: &str) -> bool {
  let mut found_differing_chars = false;
  for (l, r) in left.chars().zip(right.chars()) {
    if l != r {
      if found_differing_chars {
        return false;
      } else {
        found_differing_chars = true;
      }
    }
  }
  return found_differing_chars;
}
```

Checking if two strings are "almost equal" is similar to checking if they are equal: you compare each pair of characters from the strings one at a time. Except when you find two differing characters, instead of returning `false` immediately you record that you found a differing characters, and then make sure there are no differing characters for the rest of the string.

By zipping the `left` and `right` strings, we get an iterator that loops through both strings in parallel, yielding each pair of characters.

This passes all the tests! But I just realized I missed a case. If one string is longer than the other, `zip()` throws away the excess characters of the longer string. So if the strings are "almost equal" up to that point, they will be reported as equal. But I don't think strings of different lengths should ever be "almost equal". (Not that it matters to the puzzle we're solving, where all the input strings are the same length...) Let's add a failing test case:

```rust
assert!(!almost_equal("abcde", "abcx"));
```

To get that to pass, I think we'll just have to add an `if` statement to the top of the function that returns `false` early if the lengths are different.

```rust
fn almost_equal(left: &str, right: &str) -> bool {
  if left.len() != right.len() {
    return false;
  }

  // --snip--
}
```

Now, as always, I feel the need to refactor the `for` loop and mutable state variable into a functional style chain of iterators. Here's my first attempt:

```rust
left.chars().zip(right.chars())
  .skip_while(|(l, r)| l == r)
  .all(|(l, r)| l == r)
```

This doesn't quite work, but I think the right idea is there. We skip pairs of characters until we get two characters that are different. From that point on, all characters must be equal. This is failing the tests for at least two reasons:

1. `skip_while()` doesn't skip the failure case, so the first thing yielded to `all()` is the pair of characters that differ, so `all()` will immediately return `false`.
2. If the two strings happen to be equal, `skip_while()` will consume the whole strings and `all()` will be left with an empty iterator, which causes it to return `true`. But we want `false` in that case.

So, unfortunately we're going to have to split this expression up into multiple statements I think.

```rust
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
```

Nice, that took care of both issues! I had to read up on how to manipulate iterators in a more manual fashion by calling `next()` directly. `next()` advances the iterator (which must be mutable) and returns `Some(value)` if there was a next value, and `None` otherwise. That let's us consume the pair of differing characters, and if there were differing characters, check if the rest of the characters are equal using `all()`.

OK, now that we have `almost_equal()`, let's find the two box IDs that are almost equal! Here's the test case, from the puzzle description:

```rust
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

  assert_eq!("fgij", find_almost_equal_pair(box_ids));
}
```

My plan for this is to just compare each string to every string that comes after it using a nested `for` loop.

```rust
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
```

Those `as_ref()`s really clutter things up...

Once we find the almost equal pair of strings, we want to return a string containing all the matching characters but omitting the pair of differing characters, as the puzzle requests. To do that we `filter()` out pairs of differing characters, then `map()` to get an iterator of single characters which we `collect()` into a `String` which we then return.

Halfway through I realized it's going to need to return an `Option`. So the assert in the test now looks like this:

```rust
assert_eq!(Some("fgij".to_string()), find_almost_equal_pair(box_ids));
```

Just for fun, I want to try out `unzip()` to see how that works.

```rust
return Some(
  box_id.as_ref().chars().zip(other_box_id.as_ref().chars())
    .filter(|(l, r)| l == r)
    .unzip::<char, char, String, String>()
    .0
);
```

Well, it works! The 4 type params you seem to have to pass makes it not worth it to me though.

Time to get that gold star now!

```rust
println!(
  "Matching box ID common letters: {}",
  find_almost_equal_pair(&box_ids).unwrap()
);
```

Got it. Here is my final code for day 2:

```rust
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

  return num_containing_two * num_containing_three;
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
```
