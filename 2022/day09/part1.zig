const std = @import("std");
const absInt = std.math.absInt;

const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return Vec2 { .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn min(self: Vec2, other: Vec2) Vec2 {
        return Vec2 {
            .x = std.math.min(self.x, other.x),
            .y = std.math.min(self.y, other.y),
        };
    }

    pub fn max(self: Vec2, other: Vec2) Vec2 {
        return Vec2 {
            .x = std.math.max(self.x, other.x),
            .y = std.math.max(self.y, other.y),
        };
    }
};

const Direction = enum {
    up,
    down,
    left,
    right,

    pub fn fromChar(char: u8) Direction {
        return switch (char) {
            'U' => .up,
            'D' => .down,
            'L' => .left,
            'R' => .right,
            else => unreachable,
        };
    }

    pub fn asVector(self: Direction) Vec2 {
        return switch (self) {
            .up => Vec2 { .x = 0, .y = -1},
            .down => Vec2 { .x = 0, .y = 1},
            .left => Vec2 { .x = -1, .y = 0},
            .right => Vec2 { .x = 1, .y = 0},
        };
    }
};

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var line_buf: [1024]u8 = undefined;

    var head = Vec2 {};
    var tail = Vec2 {};

    // Uncomment for an animation!
    // var min = head;
    // var max = head;

    var been_to = std.AutoHashMap(Vec2, bool).init(std.heap.page_allocator);
    defer been_to.deinit();

    while (try reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        const dir = Direction.fromChar(line[0]);
        const num_steps = try std.fmt.parseInt(i32, line[2..], 10);

        var step: usize = 0;
        while (step < num_steps) : (step += 1) {
            head = head.add(dir.asVector());

            const dx = tail.x - head.x;
            const dy = tail.y - head.y;

            if (try absInt(dx) <= 1 and try absInt(dy) <= 1) {
                // Tail doesn't move
            } else if (dx > 1 and dy == 0) {
                tail.x -= 1;
            } else if (dx < -1 and dy == 0) {
                tail.x += 1;
            } else if (dy > 1 and dx == 0) {
                tail.y -= 1;
            } else if (dy < -1 and dx == 0) {
                tail.y += 1;
            } else {
                tail.x -= std.math.sign(dx);
                tail.y -= std.math.sign(dy);
            }

            try been_to.put(tail, true);

            // Uncomment for an animation!
            // min = min.min(head).min(tail);
            // max = max.max(head).max(tail);
            //
            // var cur_y: i32 = min.y;
            // while (cur_y <= max.y) : (cur_y += 1) {
            //    var cur_x: i32 = min.x;
            //    while (cur_x <= max.x) : (cur_x += 1) {
            //        if (head.x == cur_x and head.y == cur_y) {
            //            std.debug.print("H", .{});
            //        } else if (tail.x == cur_x and tail.y == cur_y) {
            //            std.debug.print("T", .{});
            //        } else if (cur_x == 0 and cur_y == 0) {
            //            std.debug.print("s", .{});
            //        } else if (been_to.contains(Vec2 { .x = cur_x, .y = cur_y })) {
            //            std.debug.print("#", .{});
            //        } else {
            //            std.debug.print(".", .{});
            //        }
            //    }
            //    std.debug.print("\n", .{});
            // }
            // std.debug.print("\n", .{});
            //
            // std.time.sleep(30000000);
        }
    }

    var stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ been_to.count() });
}
