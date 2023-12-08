const std = @import("std");
const assert = std.debug.assert;

// Required to set up the LetterSet below. It lets you mixin some methods into
// your set type, but we don't have anything we need to mixin.
fn LetterSetExt(comptime Self: type) type {
    _ = Self;
    return struct {};
}

// This is the only way to do set intersections through Zig's standard library -
// an IndexedSet is basically a bitset, which requires us to map our keys to an
// index space (ideally as small as possible, as the set is copied by value).
// In this case, our keys are uppercase and lowercase letters, which we map to
// the index range 0 to 51.
const LetterSet = std.enums.IndexedSet(struct {
    pub const Key = u8;
    pub const count: usize = 52;
    pub fn indexOf(k: Key) usize {
        assert(std.ascii.isAlphabetic(k));
        return if (std.ascii.isLower(k)) k - 'a' else k - 'A' + 26;
    }
    pub fn keyForIndex(index: usize) Key {
        if (index < 26) {
            return @intCast(Key, index) + 'a';
        } else {
            return @intCast(Key, index) - 26 + 'A';
        }
    }
}, LetterSetExt);

fn item_priority(item: u8) u32 {
    return if (std.ascii.isLower(item)) item - 'a' + 1 else item - 'A' + 27;
}

const group_size = 3;

pub fn main() !void {
    var input = try std.fs.cwd().openFile("input", .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var reader = buf_reader.reader();

    var sum_of_priorities: u32 = 0;

    group_loop: while (true) {
        // We'll have a set for each rucksack in this group of 3
        var rucksacks: [group_size]LetterSet = undefined;

        var i: usize = 0;
        rucksack_loop: while (i < group_size) : (i += 1) {
            // Create a rucksack, adding each letter to the LetterSet until we
            // hit a newline.
            rucksacks[i] = LetterSet {};
            while (true) {
                const byte = reader.readByte() catch break :group_loop;

                if (byte == '\n') {
                    // Done with this rucksack, move on to the next one
                    continue :rucksack_loop;
                }

                assert(std.ascii.isAlphabetic(byte));
                rucksacks[i].insert(byte);
            }
        }

        // Do a set intersection between the 3 rucksacks
        var common_items = rucksacks[0];
        common_items.setIntersection(rucksacks[1]);
        common_items.setIntersection(rucksacks[2]);

        // We should be left with one common item, which is the group's badge
        assert(common_items.count() == 1);
        var common_items_iter = common_items.iterator();
        const badge = common_items_iter.next().?;

        sum_of_priorities += item_priority(badge);
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{sum_of_priorities});
}
