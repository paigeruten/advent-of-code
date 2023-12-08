use chrono::Duration;
use chrono::prelude::*;

#[derive(Debug, PartialEq)]
pub struct Nap {
  start: DateTime<Utc>,
  end: DateTime<Utc>
}

impl Nap {
  pub fn new(start: DateTime<Utc>, end: DateTime<Utc>) -> Self {
    Nap { start, end }
  }

  pub fn len(&self) -> Duration {
    self.end - self.start - Duration::minutes(1)
  }

  pub fn minutes(&self) -> Minutes {
    Minutes {
      current: self.start,
      end: self.end
    }
  }
}

#[derive(Debug)]
pub struct Minutes {
  current: DateTime<Utc>,
  end: DateTime<Utc>
}

impl Iterator for Minutes {
  type Item = DateTime<Utc>;

  fn next(&mut self) -> Option<DateTime<Utc>> {
    let current = self.current;
    self.current = self.current + Duration::minutes(1);

    if current < self.end {
      Some(current)
    } else {
      None
    }
  }
}

impl AsRef<Nap> for Nap {
  fn as_ref(&self) -> &Nap {
    self
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_len() {
    let nap = Nap::new(
      Utc.ymd(2018, 12, 22).and_hms(0, 5, 0),
      Utc.ymd(2018, 12, 22).and_hms(1, 6, 0)
    );

    assert_eq!(nap.len(), Duration::minutes(60));
  }

  #[test]
  fn test_minutes() {
    let nap = Nap::new(
      Utc.ymd(2018, 12, 22).and_hms(0, 5, 0),
      Utc.ymd(2018, 12, 22).and_hms(0, 10, 0)
    );

    assert_eq!(
      nap.minutes().collect::<Vec<_>>(),
      vec![
        Utc.ymd(2018, 12, 22).and_hms(0, 5, 0),
        Utc.ymd(2018, 12, 22).and_hms(0, 6, 0),
        Utc.ymd(2018, 12, 22).and_hms(0, 7, 0),
        Utc.ymd(2018, 12, 22).and_hms(0, 8, 0),
        Utc.ymd(2018, 12, 22).and_hms(0, 9, 0)
      ]
    );
  }
}
