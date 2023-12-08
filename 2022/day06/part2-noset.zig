const std = @import("std");

const num_last_chars = 14;

fn all_unique(chars: []const u8) bool {
    for (chars) |char1, idx| {
        for (chars[idx+1..]) |char2| {
            if (char1 == char2) return false;
        }
    }
    return true;
}

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var last_chars: [num_last_chars]u8 = undefined;
    for (last_chars) |*ch| {
        ch.* = try reader.readByte();
    }

    var num_chars_processed: usize = num_last_chars;
    while (true) {
        if (all_unique(&last_chars)) break;

        const byte = reader.readByte() catch break;
        if (!std.ascii.isLower(byte)) continue;

        std.mem.rotate(u8, &last_chars, 1);
        last_chars[num_last_chars - 1] = byte;

        num_chars_processed += 1;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{ num_chars_processed });
}
