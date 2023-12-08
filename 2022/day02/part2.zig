const std = @import("std");

pub fn main() !void {
    // Translate puzzle input into the format expected by part 1
    try translatePuzzleInput("input", "input.tmp");

    // Overwrite the input file with our translated input
    try std.fs.cwd().rename("input", "input.orig.tmp");
    try std.fs.cwd().rename("input.tmp", "input");

    // Trick part 1 solver into solving part 2!
    const result = try std.ChildProcess.exec(.{
        .allocator = std.heap.page_allocator,
        .argv = &[_][]const u8{
            "io",
            "part1.io"
        },
    });

    // Print out result of part 1 solver
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}", .{result.stdout});

    // Put back the original input file
    try std.fs.cwd().rename("input.orig.tmp", "input");
}

fn translatePuzzleInput(inputPath: []const u8, newInputPath: []const u8) !void {
    var input = try std.fs.cwd().openFile(inputPath, .{});
    defer input.close();
    var buf_reader = std.io.bufferedReader(input.reader());
    var reader = buf_reader.reader();

    var output = try std.fs.cwd().createFile(newInputPath, .{ .read = true });
    defer output.close();
    var writer = output.writer();

    var opponent: u8 = undefined;
    while (true) {
        const byte = reader.readByte() catch break;
        const outputByte: u8 = switch (byte) {
            0 => break,

            // Remember what the opponent chooses.
            'A', 'B', 'C' => abc: {
                opponent = byte;
                break :abc byte;
            },

            // Lose: Pick the hand shape that will lose to the opponent's.
            'X' => switch (opponent) {
                'A' => 'Z',
                'B' => 'X',
                'C' => 'Y',
                else => unreachable,
            },

            // Draw: Copy the opponent's hand shape.
            'Y' => 'X' + (opponent - 'A'),

            // Win: Pick the hand shape that will win against the opponent's.
            'Z' => switch (opponent) {
                'A' => 'Y',
                'B' => 'Z',
                'C' => 'X',
                else => unreachable,
            },

            else => byte,
        };

        try writer.writeByte(outputByte);
    }
}
