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

    var stdout = std.io.getStdOut().writer();

    var reg_x: i32 = 1;
    for (bytecode.items) |inst, ip| {
        if (ip > 0 and ip % 40 == 0) {
            try stdout.print("\n", .{});
        }

        const pixel_x = ip % 40;
        if (pixel_x >= reg_x - 1 and pixel_x <= reg_x + 1) {
            try stdout.print("#", .{});
        } else {
            try stdout.print(".", .{});
        }

        reg_x += inst;
    }

    try stdout.print("\n", .{});
}
