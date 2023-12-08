use std::io;
use std::ops::Add;
use std::str::FromStr;

#[derive(Debug)]
struct Wire {
    segments: Vec<WireSegment>,
}

impl Wire {
    pub fn segments(&self) -> &[WireSegment] {
        self.segments.as_slice()
    }

    pub fn intersections_with(&self, other: &Wire) -> Vec<Intersection> {
        let mut intersections = Vec::new();

        let mut steps1 = 0;
        for segment1 in self.segments.iter() {
            let mut steps2 = 0;
            for segment2 in other.segments().iter() {
                if let Some(intersection_point) = segment1.intersection_with(segment2) {
                    let total_steps =
                        steps1 +
                        steps2 +
                        segment1.length_upto(intersection_point) +
                        segment2.length_upto(intersection_point);

                    intersections.push(Intersection {
                        point: intersection_point,
                        steps: total_steps,
                    });
                }
                steps2 += segment2.length();
            }
            steps1 += segment1.length();
        }

        intersections
    }
}

impl FromStr for Wire {
    type Err = &'static str;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let segments: Vec<WireSegment> = s
            .split(',')
            .map(|segment| {
                let direction = segment.chars().nth(0).unwrap();
                let distance = segment[1..].trim_end().parse::<i32>().unwrap();
                match direction {
                    'U' => (0, -distance),
                    'R' => (distance, 0),
                    'D' => (0, distance),
                    'L' => (-distance, 0),
                    _ => panic!("unexpected direction"),
                }
            })
            .scan(WireSegment::default(), |last_segment, delta| {
                *last_segment = WireSegment::new(
                    last_segment.end(),
                    last_segment.end() + delta
                );

                Some(*last_segment)
            })
            .collect();

        Ok(Wire { segments })
    }
}

#[derive(Debug, Default, Copy, Clone)]
struct WireSegment {
    start: Point,
    end: Point,
}

impl WireSegment {
    pub fn new(start: Point, end: Point) -> Self {
        let segment = Self { start, end };
        assert!(segment.is_vertical() || segment.is_horizontal());
        segment
    }

    pub fn start(&self) -> Point {
        self.start
    }

    pub fn end(&self) -> Point {
        self.end
    }

    pub fn is_vertical(&self) -> bool {
        self.start.x() == self.end.x()
    }

    pub fn is_horizontal(&self) -> bool {
        self.start.y() == self.end.y()
    }

    pub fn length(&self) -> i32 {
        (self.end().x() - self.start().x()).abs() +
        (self.end().y() - self.start().y()).abs()
    }

    pub fn length_upto(&self, point: Point) -> i32 {
        WireSegment {
            start: self.start(),
            end: point,
        }.length()
    }

    pub fn contains_x(&self, x: i32) -> bool {
        if self.start().x() <= self.end().x() {
            x >= self.start().x() && x <= self.end().x()
        } else {
            x >= self.end().x() && x <= self.start().x()
        }
    }

    pub fn contains_y(&self, y: i32) -> bool {
        if self.start().y() <= self.end().y() {
            y >= self.start().y() && y <= self.end().y()
        } else {
            y >= self.end().y() && y <= self.start().y()
        }
    }

    pub fn intersection_with(&self, other: &WireSegment) -> Option<Point> {
        match (self.is_vertical(), other.is_vertical()) {
            // Vertical intersects with horizontal?
            (true, false)
                if other.contains_x(self.start().x())
                    && self.contains_y(other.start().y())
                        => Some(Point(self.start().x(), other.start().y())),

            // Horizontal intersects with vertical?
            (false, true)
                if self.contains_x(other.start().x())
                    && other.contains_y(self.start().y())
                        => Some(Point(other.start().x(), self.start().y())),

            // Both vertical, or both horizontal - so they don't intersect.
            _ => None
        }
    }
}

#[derive(Debug, Default, Copy, Clone, PartialEq)]
struct Point(i32, i32);

impl Point {
    pub fn x(self) -> i32 {
        self.0
    }

    pub fn y(self) -> i32 {
        self.1
    }

    pub fn manhattan_distance(self) -> i32 {
        self.x().abs() + self.y().abs()
    }
}

impl Add<(i32, i32)> for Point {
    type Output = Self;

    fn add(self, delta: (i32, i32)) -> Self {
        Point(self.0 + delta.0, self.1 + delta.1)
    }
}

#[derive(Debug, Copy, Clone)]
struct Intersection {
    point: Point,
    steps: i32,
}

fn main() {
    let mut line = String::new();
    io::stdin().read_line(&mut line).expect("Expected 2 wires in input.");
    let wire1 = line.parse::<Wire>().unwrap();

    let mut line = String::new();
    io::stdin().read_line(&mut line).expect("Expected 2 wires in input.");
    let wire2 = line.parse::<Wire>().unwrap();

    let intersections = wire1.intersections_with(&wire2);

    let closest = intersections.iter()
        .map(|intersection| intersection.point)
        .filter(|&point| point != Point(0, 0))
        .min_by_key(|point| point.manhattan_distance())
        .unwrap();

    println!("Part 1 solution: {}", closest.manhattan_distance());

    let fewest_steps = intersections.iter()
        .map(|intersection| intersection.steps)
        .min()
        .unwrap();

    println!("Part 2 solution: {}", fewest_steps);
}
