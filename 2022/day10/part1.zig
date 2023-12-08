const std = @import("std");
const startsWith = std.mem.startsWith;
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var line_buf: [32]u8 = undefined;

    var bytecode = ArrayList(i32).init(std.heap.page_allocator);
    defer bytecode.deinit();

    while (try reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        if (startsWith(u8, line, "noop")) {
            try bytecode.append(0);
        } else if (startsWith(u8, line, "addx")) {
            try bytecode.append(0);
            try bytecode.append(try parseInt(i32, line[5..], 10));
        } else unreachable;
    }

    var total_signal_strength: i32 = 0;
    var reg_x: i32 = 1;
    var cur_cycle: usize = 1;
    while (cur_cycle <= 220) : (cur_cycle += 1) {
        if ((cur_cycle + 20) % 40 == 0) {
            total_signal_strength += @intCast(i32, cur_cycle) * reg_x;
        }

        reg_x += bytecode.items[cur_cycle - 1];
    }

    var stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{total_signal_strength});
}
