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

    const rope_len = 10;
    var rope: [rope_len]Vec2 = undefined;

    for (rope) |*knot| {
        knot.* = Vec2 {};
    }

    // Uncomment for an animation!
    // var min = Vec2 {};
    // var max = Vec2 {};

    var been_to = std.AutoHashMap(Vec2, bool).init(std.heap.page_allocator);
    defer been_to.deinit();

    while (try reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        const dir = Direction.fromChar(line[0]);
        const num_steps = try std.fmt.parseInt(i32, line[2..], 10);

        var step: usize = 0;
        while (step < num_steps) : (step += 1) {
            rope[0] = rope[0].add(dir.asVector());

            var idx: usize = 1;
            while (idx < rope_len) : (idx += 1) {
                const dx = rope[idx].x - rope[idx-1].x;
                const dy = rope[idx].y - rope[idx-1].y;

                if (try absInt(dx) <= 1 and try absInt(dy) <= 1) {
                    // Knot doesn't move
                } else if (dx > 1 and dy == 0) {
                    rope[idx].x -= 1;
                } else if (dx < -1 and dy == 0) {
                    rope[idx].x += 1;
                } else if (dy > 1 and dx == 0) {
                    rope[idx].y -= 1;
                } else if (dy < -1 and dx == 0) {
                    rope[idx].y += 1;
                } else {
                    rope[idx].x -= std.math.sign(dx);
                    rope[idx].y -= std.math.sign(dy);
                }
            }

            try been_to.put(rope[rope_len-1], true);

            // Uncomment for an animation!
            // for (rope) |knot| {
            //     min = min.min(knot);
            //     max = max.max(knot);
            // }
            //
            // var cur_y: i32 = min.y;
            // while (cur_y <= max.y) : (cur_y += 1) {
            //     var cur_x: i32 = min.x;
            //     while (cur_x <= max.x) : (cur_x += 1) {
            //         const knot_char: ?u8 = for (rope) |knot, knot_idx| {
            //             if (cur_x == knot.x and cur_y == knot.y) {
            //                 break if (knot_idx == 0) 'H' else @intCast(u8, knot_idx) + '0';
            //             }
            //         } else null;
            //
            //         if (knot_char) |char| {
            //             std.debug.print("{c}", .{ char });
            //         } else if (cur_x == 0 and cur_y == 0) {
            //             std.debug.print("s", .{});
            //         } else if (been_to.contains(Vec2 { .x = cur_x, .y = cur_y })) {
            //             std.debug.print("#", .{});
            //         } else {
            //             std.debug.print(".", .{});
            //         }
            //     }
            //     std.debug.print("\n", .{});
            // }
            // std.debug.print("\n", .{});
            //
            // std.time.sleep(30000000);
        }
    }

    var stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ been_to.count() });
}
