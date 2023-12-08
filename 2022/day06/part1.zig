const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    // Keep track of last 3 chars seen
    var a = try reader.readByte();
    var b = try reader.readByte();
    var c = try reader.readByte();

    var num_chars_processed: usize = 3;
    while (reader.readByte() catch null) |byte| {
        if (!std.ascii.isLower(byte)) continue;

        num_chars_processed += 1;

        if (a != b and a != c and a != byte and b != c and b != byte and c != byte) {
            break;
        }

        a = b;
        b = c;
        c = byte;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ num_chars_processed });
}
