const std = @import("std");
const assert = std.debug.assert;

const num_last_chars = 14;

const LetterSet = std.enums.IndexedSet(struct {
    pub const Key = u8;
    pub const count: usize = 26;
    pub fn indexOf(k: Key) usize {
        assert(std.ascii.isLower(k));
        return k - 'a';
    }
    pub fn keyForIndex(index: usize) Key {
        return @intCast(Key, index) + 'a';
    }
}, std.enums.NoExtension);

fn all_unique(chars: []const u8) bool {
    var set = LetterSet {};
    for (chars) |char| {
        if (set.contains(char)) return false;
        set.insert(char);
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
