use chrono::prelude::*;
use lazy_static::lazy_static;
use regex::Regex;
use std::str::FromStr;

#[derive(Debug, PartialEq)]
pub enum Event {
  BeginShift(u32),
  FallAsleep,
  WakeUp
}

#[derive(Debug, PartialEq)]
pub struct LogEntry {
  pub timestamp: DateTime<Utc>,
  pub event: Event
}

impl FromStr for LogEntry {
  type Err = ();

  fn from_str(s: &str) -> Result<Self, ()> {
    lazy_static! {
      static ref LINE_REGEX: Regex =
        Regex::new(r"^\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (.+)$").unwrap();
      static ref BEGIN_SHIFT_REGEX: Regex =
        Regex::new(r"^Guard #(\d+) begins shift$").unwrap();
    }

    if let Some(caps) = LINE_REGEX.captures(s) {
      let year:   i32 = caps.get(1).unwrap().as_str().parse().unwrap();
      let month:  u32 = caps.get(2).unwrap().as_str().parse().unwrap();
      let day:    u32 = caps.get(3).unwrap().as_str().parse().unwrap();
      let hour:   u32 = caps.get(4).unwrap().as_str().parse().unwrap();
      let minute: u32 = caps.get(5).unwrap().as_str().parse().unwrap();

      let timestamp = Utc.ymd(year, month, day).and_hms(hour, minute, 0);

      let event_str = caps.get(6).unwrap().as_str();
      if let Some(caps) = BEGIN_SHIFT_REGEX.captures(event_str) {
        let guard_id: u32 = caps.get(1).unwrap().as_str().parse().unwrap();
        Ok(LogEntry { timestamp, event: Event::BeginShift(guard_id) })
      } else if event_str == "falls asleep" {
        Ok(LogEntry { timestamp, event: Event::FallAsleep })
      } else if event_str == "wakes up" {
        Ok(LogEntry { timestamp, event: Event::WakeUp })
      } else {
        Err(())
      }
    } else {
      Err(())
    }
  }
}

impl AsRef<LogEntry> for LogEntry {
  fn as_ref(&self) -> &LogEntry {
    self
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_log_entry_parse() {
    assert_eq!(
      "[1518-10-31 23:28] Guard #10 begins shift".parse::<LogEntry>().unwrap(),
      LogEntry {
        timestamp: Utc.ymd(1518, 10, 31).and_hms(23, 28, 0),
        event: Event::BeginShift(10)
      }
    );
    assert_eq!(
      "[1518-11-01 00:05] falls asleep".parse::<LogEntry>().unwrap(),
      LogEntry {
        timestamp: Utc.ymd(1518, 11, 1).and_hms(0, 5, 0),
        event: Event::FallAsleep
      }
    );
    assert_eq!(
      "[1518-11-01 00:25] wakes up".parse::<LogEntry>().unwrap(),
      LogEntry {
        timestamp: Utc.ymd(1518, 11, 1).and_hms(0, 25, 0),
        event: Event::WakeUp
      }
    );
  }
}
