const std = @import("std");

pub fn main() !void {
    // Open input file and prepare to read line by line.
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    // Read lines and keep track of elf calories.
    var elf_calories: [1024]u32 = undefined;
    var num_elves: usize = 0;
    var calories_sum: u32 = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) {
            elf_calories[num_elves] = calories_sum;
            num_elves += 1;
            calories_sum = 0;
        } else {
            calories_sum += try std.fmt.parseInt(u32, line, 10);
        }
    }

    // Append final elf calories, in case there was no final blank line.
    if (calories_sum > 0) {
        elf_calories[num_elves] = calories_sum;
        num_elves += 1;
    }

    // Sort the elve's total calories in descending order.
    std.sort.sort(u32, elf_calories[0..num_elves], {}, std.sort.desc(u32));

    // Sum up the top three.
    const sum_of_top_3 = elf_calories[0] + elf_calories[1] + elf_calories[2];

    // Print out the sum.
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{}\n", .{sum_of_top_3});
}
