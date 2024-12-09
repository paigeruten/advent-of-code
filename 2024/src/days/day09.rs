use std::{fmt::Display, io::BufRead};

use crate::common::{Part, Solution};

pub fn solve(part: Part, input: impl BufRead) -> color_eyre::Result<Solution> {
    let solution = match part {
        Part::One => {
            let mut disk = Disk::from_disk_map(&DiskMap::parse(input)?);
            disk.defragment();
            disk.checksum()
        }
        Part::Two => {
            let mut disk_map = DiskMap::parse(input)?;
            disk_map.defragment();
            Disk::from_disk_map(&disk_map).checksum()
        }
    };

    Ok(Solution::Num(solution as i64))
}

type FileId = u64;

#[derive(Debug)]
struct DiskMap(Vec<DiskMapRange>);

#[derive(Debug)]
struct DiskMapRange {
    file_id: Option<FileId>,
    size: usize,
}

impl DiskMap {
    pub fn parse(input: impl BufRead) -> color_eyre::Result<Self> {
        let mut ranges = Vec::new();
        let mut is_file = true;
        let mut file_id = 0;

        for digit in input.bytes() {
            let digit = digit?;
            if digit.is_ascii_digit() {
                let size = (digit - b'0') as usize;
                if is_file {
                    ranges.push(DiskMapRange {
                        file_id: Some(file_id),
                        size,
                    });
                    file_id += 1;
                } else {
                    ranges.push(DiskMapRange {
                        file_id: None,
                        size,
                    });
                }
                is_file = !is_file;
            }
        }

        Ok(Self(ranges))
    }

    pub fn defragment(&mut self) {
        let ranges = &mut self.0;
        let mut first_free = 0;
        let mut cur_file = ranges.len() - 1;

        while first_free < cur_file {
            if ranges[first_free].file_id.is_some() {
                first_free += 1;
            } else if ranges[cur_file].file_id.is_none() {
                cur_file -= 1;
            } else if let Some(cur_free) = ranges[first_free..cur_file]
                .iter()
                .position(|range| range.file_id.is_none() && range.size >= ranges[cur_file].size)
            {
                let cur_free = first_free + cur_free;
                let leftover_space = ranges[cur_free].size - ranges[cur_file].size;
                ranges.swap(cur_free, cur_file);
                if leftover_space == 0 {
                    cur_file -= 1;
                } else {
                    ranges.insert(
                        cur_free + 1,
                        DiskMapRange {
                            file_id: None,
                            size: leftover_space,
                        },
                    );
                    ranges[cur_file + 1].size = ranges[cur_free].size;
                }
            } else {
                cur_file -= 1;
            }
        }
    }
}

#[derive(Debug)]
struct Disk {
    blocks: Vec<Option<FileId>>,
}

impl Disk {
    pub fn from_disk_map(disk_map: &DiskMap) -> Self {
        let mut blocks = Vec::new();
        for range in disk_map.0.iter() {
            for _ in 0..range.size {
                blocks.push(range.file_id);
            }
        }
        Disk { blocks }
    }

    pub fn defragment(&mut self) {
        let mut left = 0;
        let mut right = self.blocks.len() - 1;

        while left < right {
            if self.blocks[left].is_some() {
                left += 1;
            } else if self.blocks[right].is_none() {
                right -= 1;
            } else {
                self.blocks.swap(left, right);
                left += 1;
                right -= 1;
            }
        }

        self.blocks.truncate(left + 1);
    }

    pub fn checksum(&self) -> u64 {
        self.blocks
            .iter()
            .enumerate()
            .map(|(index, file_id)| index as u64 * file_id.unwrap_or(0))
            .sum()
    }
}

impl Display for Disk {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        for block in &self.blocks {
            match block {
                Some(file_id) => write!(f, "{file_id}")?,
                None => write!(f, ".")?,
            }
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::file_reader;
    use std::io::Cursor;

    const EXAMPLE_INPUT: &str = "2333133121414131402";

    #[test]
    fn solve_part_one_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(1928), solve(Part::One, input).unwrap());
    }

    #[test]
    fn solve_part_one() {
        let input = file_reader("input/day09").unwrap();
        assert_eq!(
            Solution::Num(6307275788409),
            solve(Part::One, input).unwrap()
        );
    }

    #[test]
    fn solve_part_two_example() {
        let input = Cursor::new(EXAMPLE_INPUT);
        assert_eq!(Solution::Num(2858), solve(Part::Two, input).unwrap());
    }

    #[test]
    fn solve_part_two() {
        let input = file_reader("input/day09").unwrap();
        assert_eq!(
            Solution::Num(6327174563252),
            solve(Part::Two, input).unwrap()
        );
    }
}
