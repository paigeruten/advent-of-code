const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const sort = std.sort.sort;

const Monkey = struct {
    items: ArrayList(i64),
    operation: Op,
    test_divisible_by: i64,
    throw_if_true: usize,
    throw_if_false: usize,
    num_inspections: usize = 0,
};

const Op = union(enum) {
    add: i64,
    mult: i64,
    square: void,
};

fn literalArrayList(allocator: Allocator, items: anytype) !ArrayList(i64) {
    const items_fields = @typeInfo(@TypeOf(items)).Struct.fields;

    var ary = try ArrayList(i64).initCapacity(allocator, items_fields.len);
    inline for (items_fields) |field| {
        ary.appendAssumeCapacity(@field(items, field.name));
    }
    return ary;
}

fn cmpByNumInspectionsDesc(context: void, a: Monkey, b: Monkey) bool {
    return std.sort.desc(usize)(context, a.num_inspections, b.num_inspections);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var monkeys = [_]Monkey {
        .{
            .items = try literalArrayList(allocator, .{91, 54, 70, 61, 64, 64, 60, 85}),
            .operation = Op { .mult = 13 },
            .test_divisible_by = 2,
            .throw_if_true = 5,
            .throw_if_false = 2,
        },
        .{
            .items = try literalArrayList(allocator, .{82}),
            .operation = Op { .add = 7 },
            .test_divisible_by = 13,
            .throw_if_true = 4,
            .throw_if_false = 3,
        },
        .{
            .items = try literalArrayList(allocator, .{84, 93, 70}),
            .operation = Op { .add = 2 },
            .test_divisible_by = 5,
            .throw_if_true = 5,
            .throw_if_false = 1,
        },
        .{
            .items = try literalArrayList(allocator, .{78, 56, 85, 93}),
            .operation = Op { .mult = 2 },
            .test_divisible_by = 3,
            .throw_if_true = 6,
            .throw_if_false = 7,
        },
        .{
            .items = try literalArrayList(allocator, .{64, 57, 81, 95, 52, 71, 58}),
            .operation = Op { .square = {} },
            .test_divisible_by = 11,
            .throw_if_true = 7,
            .throw_if_false = 3,
        },
        .{
            .items = try literalArrayList(allocator, .{58, 71, 96, 58, 68, 90}),
            .operation = Op { .add = 6 },
            .test_divisible_by = 17,
            .throw_if_true = 4,
            .throw_if_false = 1,
        },
        .{
            .items = try literalArrayList(allocator, .{56, 99, 89, 97, 81}),
            .operation = Op { .add = 1 },
            .test_divisible_by = 7,
            .throw_if_true = 0,
            .throw_if_false = 2,
        },
        .{
            .items = try literalArrayList(allocator, .{68, 72}),
            .operation = Op { .add = 8 },
            .test_divisible_by = 19,
            .throw_if_true = 6,
            .throw_if_false = 0,
        },
    };
    defer for (monkeys) |monkey| {
        monkey.items.deinit();
    };

    var max_worry_level: i64 = 1;
    for (monkeys) |monkey| {
        max_worry_level *= monkey.test_divisible_by;
    }

    var round: usize = 1;
    while (round <= 10_000) : (round += 1) {
        for (monkeys) |*monkey| {
            while (monkey.items.items.len > 0) {
                var item = monkey.items.orderedRemove(0);

                // Inspect item
                item = switch (monkey.operation) {
                    .add => |value| item + value,
                    .mult => |value| item * value,
                    .square => item * item,
                };
                monkey.num_inspections += 1;

                // Phew!
                item = @mod(item, max_worry_level);

                // Test item
                const recipient = if (@mod(item, monkey.test_divisible_by) == 0)
                    monkey.throw_if_true else monkey.throw_if_false;

                // Throw item to another monkey
                try monkeys[recipient].items.append(item);
            }
        }
    }

    sort(Monkey, &monkeys, {}, cmpByNumInspectionsDesc);

    const monkey_business_level =
        monkeys[0].num_inspections * monkeys[1].num_inspections;

    std.debug.print("{}\n", .{monkey_business_level});
}
