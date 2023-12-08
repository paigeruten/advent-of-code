const std = @import("std");
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;

const Stack = ArrayList(u8);

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var line_buf: [1024]u8 = undefined;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var stacks = ArrayList(Stack).init(allocator);

    // Parse initial stack configuration
    while (try reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        // Parse rows of crates until we hit the row of crate numbers
        if (std.mem.startsWith(u8, line, " 1  ")) break;

        const num_stacks = (line.len + 1) / 4;

        while (stacks.items.len < num_stacks) {
            try stacks.append(Stack.init(allocator));
        }

        var i: usize = 0;
        while (i < num_stacks) : (i += 1) {
            const crate = line[i*4 + 1];
            if (std.ascii.isUpper(crate)) {
                try stacks.items[i].insert(0, crate);
            }
        }
    }

    // Process the moves
    while (try reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        if (!std.mem.startsWith(u8, line, "move")) continue;

        // Parse the numbers out of the line "move X from Y to Z"
        var it = std.mem.tokenize(u8, line, " ");
        _ = it.next().?;
        const count = try parseInt(usize, it.next().?, 10);
        _ = it.next().?;
        const from_stack_idx = try parseInt(usize, it.next().?, 10) - 1;
        _ = it.next().?;
        const to_stack_idx = try parseInt(usize, it.next().?, 10) - 1;

        var from_stack = &stacks.items[from_stack_idx];
        var to_stack = &stacks.items[to_stack_idx];

        try to_stack.appendSlice(from_stack.items[from_stack.items.len - count..]);
        try from_stack.replaceRange(from_stack.items.len - count, count, &[_]u8{});

        // Uncomment for an animation!
        //std.time.sleep(100000000);
        //try printStacks(stacks.items);
    }

    try printStacks(stacks.items);

    // Print out top-most crate of each stack
    var stdout = std.io.getStdOut().writer();
    for (stacks.items) |stack| {
        try stdout.print("{c}", .{stack.items[stack.items.len - 1]});
    }
    try stdout.print("\n", .{});
}

fn printStacks(stacks: []Stack) !void {
    var stdout = std.io.getStdOut().writer();

    var max_crates: usize = 0;
    for (stacks) |stack| {
        max_crates = std.math.max(max_crates, stack.items.len);
    }

    var row: usize = 0;
    while (row < max_crates) : (row += 1) {
        const crate_index = max_crates - row - 1;
        for (stacks) |stack| {
            if (crate_index < stack.items.len) {
                try stdout.print("[{c}] ", .{stack.items[crate_index]});
            } else {
                try stdout.print("    ", .{});
            }
        }
        try stdout.print("\n", .{});
    }

    for (stacks) |_, index| {
        try stdout.print(" {}  ", .{index + 1});
    }

    try stdout.print("\n\n", .{});
}
