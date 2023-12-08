use chrono::prelude::*;
use std::collections::HashMap;
use std::fs::File;
use std::io::BufReader;
use std::io::prelude::*;

mod log;
mod nap;

use self::log::{Event, LogEntry};
use self::nap::Nap;

pub fn solve(input_file: File) {
  let reader = BufReader::new(input_file);

  let mut log_entries: Vec<LogEntry> = reader
    .lines()
    .flatten()
    .map(|line| line.parse())
    .flatten()
    .collect();

  log_entries.sort_by_key(|e| e.timestamp);

  let naps_by_guard_id = collect_naps(&log_entries);

  let max_minutes_by_guard_id = naps_by_guard_id.iter().map(|(&guard_id, naps)| {
    (guard_id, max_minute(naps))
  }).collect::<HashMap<_, _>>();

  let (guard_id_1, max_minute_1) = strategy_1(&naps_by_guard_id, &max_minutes_by_guard_id);
  let (guard_id_2, max_minute_2) = strategy_2(&max_minutes_by_guard_id);

  println!(
    "Strategy 1: Guard {} * Minute {} = {}",
    guard_id_1, max_minute_1, guard_id_1 * max_minute_1
  );
  println!(
    "Strategy 2: Guard {} * Minute {} = {}",
    guard_id_2, max_minute_2, guard_id_2 * max_minute_2
  );
}

fn strategy_1(naps_by_guard_id: &HashMap<u32, Vec<Nap>>, max_minutes_by_guard_id: &HashMap<u32, (u32, u32)>) -> (u32, u32) {
  let &guard_id = naps_by_guard_id.iter()
    .max_by_key(|(_, naps)| naps.iter()
      .map(|nap| nap.len().num_minutes())
      .sum::<i64>())
    .unwrap()
    .0;

  let max_minute = max_minutes_by_guard_id[&guard_id].0;

  (guard_id, max_minute)
}

fn strategy_2(max_minutes_by_guard_id: &HashMap<u32, (u32, u32)>) -> (u32, u32) {
  let (&guard_id, &(max_minute, _)) = max_minutes_by_guard_id.iter()
    .max_by_key(|(_, (_, n))| n)
    .unwrap();

  (guard_id, max_minute)
}

fn collect_naps<T: AsRef<LogEntry>>(sorted_log_entries: &[T]) -> HashMap<u32, Vec<Nap>> {
  let mut naps_by_guard_id: HashMap<u32, Vec<Nap>> = HashMap::new();
  let mut current_guard_id = None;
  let mut nap_start = None;

  for log_entry in sorted_log_entries.iter() {
    let log_entry = log_entry.as_ref();
    match log_entry.event {
      Event::BeginShift(guard_id) => {
        current_guard_id = Some(guard_id);
      },
      Event::FallAsleep => {
        nap_start = Some(log_entry.timestamp);
      },
      Event::WakeUp => {
        naps_by_guard_id
          .entry(current_guard_id.unwrap())
          .or_default()
          .push(Nap::new(nap_start.unwrap(), log_entry.timestamp));

        nap_start = None;
      }
    }
  }

  naps_by_guard_id
}

fn max_minute<T: AsRef<Nap>>(naps: &[T]) -> (u32, u32) {
  let mut minutes = HashMap::new();

  for nap in naps.iter() {
    for timestamp in nap.as_ref().minutes() {
      *minutes.entry(timestamp.minute()).or_insert(0) += 1;
    }
  }

  let (&minute, &n) = minutes.iter()
    .max_by_key(|(_, &n)| n)
    .unwrap();

  (minute, n)
}

#[cfg(test)]
mod tests {
  use super::*;

  fn log_entries() -> Vec<LogEntry> {
    vec![
      "[1518-11-01 00:00] Guard #10 begins shift".parse().unwrap(),
      "[1518-11-01 00:05] falls asleep".parse().unwrap(),
      "[1518-11-01 00:25] wakes up".parse().unwrap(),
      "[1518-11-01 00:30] falls asleep".parse().unwrap(),
      "[1518-11-01 00:55] wakes up".parse().unwrap(),
      "[1518-11-01 23:58] Guard #99 begins shift".parse().unwrap(),
      "[1518-11-02 00:40] falls asleep".parse().unwrap(),
      "[1518-11-02 00:50] wakes up".parse().unwrap(),
      "[1518-11-03 00:05] Guard #10 begins shift".parse().unwrap(),
      "[1518-11-03 00:24] falls asleep".parse().unwrap(),
      "[1518-11-03 00:29] wakes up".parse().unwrap(),
      "[1518-11-04 00:02] Guard #99 begins shift".parse().unwrap(),
      "[1518-11-04 00:36] falls asleep".parse().unwrap(),
      "[1518-11-04 00:46] wakes up".parse().unwrap(),
      "[1518-11-05 00:03] Guard #99 begins shift".parse().unwrap(),
      "[1518-11-05 00:45] falls asleep".parse().unwrap(),
      "[1518-11-05 00:55] wakes up".parse().unwrap(),
    ]
  }

  #[test]
  fn test_collect_naps() {
    let entries = log_entries();
    let naps_by_guard_id = collect_naps(&entries);

    assert_eq!(
      naps_by_guard_id[&10],
      &[
        Nap::new(
          Utc.ymd(1518, 11, 01).and_hms(0, 5, 0),
          Utc.ymd(1518, 11, 01).and_hms(0, 25, 0)
        ),
        Nap::new(
          Utc.ymd(1518, 11, 01).and_hms(0, 30, 0),
          Utc.ymd(1518, 11, 01).and_hms(0, 55, 0)
        ),
        Nap::new(
          Utc.ymd(1518, 11, 03).and_hms(0, 24, 0),
          Utc.ymd(1518, 11, 03).and_hms(0, 29, 0)
        )
      ]
    );

    assert_eq!(
      naps_by_guard_id[&99],
      &[
        Nap::new(
          Utc.ymd(1518, 11, 02).and_hms(0, 40, 0),
          Utc.ymd(1518, 11, 02).and_hms(0, 50, 0)
        ),
        Nap::new(
          Utc.ymd(1518, 11, 04).and_hms(0, 36, 0),
          Utc.ymd(1518, 11, 04).and_hms(0, 46, 0)
        ),
        Nap::new(
          Utc.ymd(1518, 11, 05).and_hms(0, 45, 0),
          Utc.ymd(1518, 11, 05).and_hms(0, 55, 0)
        )
      ]
    )
  }

  #[test]
  fn test_max_minute() {
    let naps = vec![
      Nap::new(
        Utc.ymd(1518, 11, 01).and_hms(0, 5, 0),
        Utc.ymd(1518, 11, 01).and_hms(0, 25, 0)
      ),
      Nap::new(
        Utc.ymd(1518, 11, 01).and_hms(0, 30, 0),
        Utc.ymd(1518, 11, 01).and_hms(0, 55, 0)
      ),
      Nap::new(
        Utc.ymd(1518, 11, 03).and_hms(0, 24, 0),
        Utc.ymd(1518, 11, 03).and_hms(0, 29, 0)
      )
    ];

    assert_eq!(
      max_minute(&naps),
      (24, 2)
    );
  }

  #[test]
  fn test_strategy_1() {
    let entries = log_entries();
    let naps_by_guard_id = collect_naps(&entries);
    let max_minutes_by_guard_id = naps_by_guard_id.iter().map(|(&guard_id, naps)| {
      (guard_id, max_minute(naps))
    }).collect::<HashMap<_, _>>();

    assert_eq!(
      strategy_1(&naps_by_guard_id, &max_minutes_by_guard_id),
      (10, 24)
    );
  }

  #[test]
  fn test_strategy_2() {
    let entries = log_entries();
    let naps_by_guard_id = collect_naps(&entries);
    let max_minutes_by_guard_id = naps_by_guard_id.iter().map(|(&guard_id, naps)| {
      (guard_id, max_minute(naps))
    }).collect::<HashMap<_, _>>();

    assert_eq!(
      strategy_2(&max_minutes_by_guard_id),
      (99, 45)
    );
  }
}
