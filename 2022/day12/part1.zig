const std = @import("std");

const Position = struct {
    x: usize,
    y: usize,

    fn fromIndex(index: usize, width: usize) Position {
        return Position {
            .x = index % width,
            .y = index / width,
        };
    }

    fn toIndex(self: Position, width: usize) usize {
        return self.y * width + self.x;
    }
};

const QueueContext = struct {
    dist: []const usize,
};

fn queueCmp(context: QueueContext, a: usize, b: usize) bool {
    return std.sort.desc(usize)({}, context.dist[a], context.dist[b]);
}

const Board = struct {
    grid: []u8,
    width: usize,
    height: usize,
    start_idx: usize,
    end_idx: usize,

    fn findShortestPathLength(self: *const Board, allocator: std.mem.Allocator) !usize {
        var dist = try std.ArrayList(usize).initCapacity(allocator, self.grid.len);
        defer dist.deinit();

        for (self.grid) |_| {
            dist.appendAssumeCapacity(std.math.maxInt(usize));
        }

        dist.items[self.start_idx] = 0;

        const queue_context = QueueContext { .dist = dist.items };
        var queue = std.ArrayList(usize).init(allocator);
        defer queue.deinit();

        for (self.grid) |_, index| {
            try queue.append(index);
        }

        queue_loop: while (queue.items.len > 0) {
            std.sort.sort(usize, queue.items, queue_context, queueCmp);

            const cur_cell = queue.pop();
            const cur_dist = dist.items[cur_cell];

            if (cur_dist == std.math.maxInt(usize)) {
                break;
            }

            for (self.findNeighbors(cur_cell)) |maybe_neighbor| {
                if (maybe_neighbor) |neighbor| {
                    const neighbor_dist = &dist.items[neighbor];
                    if (cur_dist + 1 < neighbor_dist.*) {
                        neighbor_dist.* = cur_dist + 1;
                    }
                    if (neighbor == self.end_idx) break :queue_loop;
                }
            }
        }

        return dist.items[self.end_idx];
    }

    fn findNeighbors(self: *const Board, index: usize) [4]?usize {
        var neighbors = [4]?usize { null, null, null, null };

        const pos = Position.fromIndex(index, self.width);
        const from_elevation = self.elevation(pos);

        if (pos.x > 0) {
            const left = Position { .x = pos.x - 1, .y = pos.y };
            if (from_elevation >= self.elevation(left) - 1) {
                neighbors[0] = left.toIndex(self.width);
            }
        }
        if (pos.x < self.width - 1) {
            const right = Position { .x = pos.x + 1, .y = pos.y };
            if (from_elevation >= self.elevation(right) - 1) {
                neighbors[1] = right.toIndex(self.width);
            }
        }
        if (pos.y > 0) {
            const up = Position { .x = pos.x, .y = pos.y - 1 };
            if (from_elevation >= self.elevation(up) - 1) {
                neighbors[2] = up.toIndex(self.width);
            }
        }
        if (pos.y < self.height - 1) {
            const down = Position { .x = pos.x, .y = pos.y + 1 };
            if (from_elevation >= self.elevation(down) - 1) {
                neighbors[3] = down.toIndex(self.width);
            }
        }

        return neighbors;
    }

    fn elevation(self: *const Board, pos: Position) usize {
        return switch(self.grid[pos.toIndex(self.width)]) {
            'S' => 1,
            'E' => 26,
            else => |char| char - 'a' + 1,
        };
    }
};

pub fn main() !void {
    var allocator = std.heap.page_allocator;

    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    var grid = std.ArrayList(u8).init(allocator);
    defer grid.deinit();

    var width: usize = undefined;
    var height: usize = 0;

    var start_idx: usize = undefined;
    var end_idx: usize = undefined;

    var i: usize = 0;
    while (reader.readByte() catch null) |char| {
        if (char == '\n') {
            if (height == 0) {
                width = i;
            }
            height += 1;
            continue;
        } else if (char == 'S') {
            start_idx = i;
        } else if (char == 'E') {
            end_idx = i;
        }

        try grid.append(char);
        i += 1;
    }

    var board = Board {
        .grid = grid.items,
        .width = width,
        .height = height,
        .start_idx = start_idx,
        .end_idx = end_idx,
    };

    std.debug.print("{}\n", .{try board.findShortestPathLength(allocator)});
}
