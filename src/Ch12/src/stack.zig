const std = @import("std");
const testing = std.testing;

const Allocator = std.mem.Allocator;
const LinkedList = std.SinglyLinkedList;

pub fn ListStack(comptime T: type) type {
    const LLNode = struct {
        data: T,
        node: LinkedList.Node = .{},
    };

    return struct {
        _items: LinkedList = .{},
        _allocator: Allocator,

        const Self = @This();

        pub fn init(allocator: Allocator) Self {
            return .{
                ._allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self._items.first) |node| {
                self._items.remove(node);
                const item: *LLNode = @fieldParentPtr("node", node);
                self._allocator.destroy(item);
            }
        }

        pub fn push(self: *Self, item: T) !void {
            var item_node = try self._allocator.create(LLNode);
            errdefer self._allocator.destroy(item_node);

            item_node.data = item;
            self._items.prepend(&item_node.node);
        }

        pub fn pop(self: *Self) !T {
            if (self._items.popFirst()) |node| {
                const item_node: *LLNode = @fieldParentPtr("node", node);
                defer self._allocator.destroy(item_node);

                return item_node.data;
            } else std.debug.panic(
                "List stack contains 0 elements. Ensure that something has been pushed onto the stack before attempting a pop operation.",
                .{},
            );
        }

        pub fn peek(self: Self) !T {
            if (self._items.first) |node| {
                const item_node: *LLNode = @fieldParentPtr("node", node);

                return item_node.data;
            } else std.debug.panic(
                "List stack contains 0 elements. Ensure that something has been pushed onto the stack before attempting a peek operation.",
                .{},
            );
        }
    };
}

test "ListStack push and peek" {
    var stack = ListStack([]const u8).init(testing.allocator);
    defer stack.deinit();

    try stack.push("John");
    const val = try stack.peek();
    try testing.expectEqual(val, "John");
}

test "ListStack pop and peek" {
    var stack = ListStack([]const u8).init(testing.allocator);
    defer stack.deinit();

    try stack.push("John");
    try stack.push("Doe");

    const popped = try stack.pop();
    try testing.expectEqual(popped, "Doe");

    const peeked = try stack.peek();
    try testing.expectEqual(peeked, "John");
}

pub fn ArrayStack(comptime T: type) type {
    return struct {
        capacity: usize,
        length: usize,
        _items: []T,
        _allocator: Allocator,

        const Self = @This();

        pub fn init(allocator: Allocator, capacity: usize) !Self {
            const items = try allocator.alloc(T, capacity);

            return .{
                .capacity = capacity,
                .length = 0,
                ._items = items,
                ._allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self._allocator.free(self._items);
        }

        pub fn push(self: *Self, item: T) !void {
            if (self.length >= self.capacity) {
                const doubled_items = try self._allocator.alloc(T, self.capacity * 2);
                errdefer self._allocator.free(doubled_items);

                @memcpy(doubled_items[0..self.capacity], self._items[0..self.capacity]);
                self._allocator.free(self._items);

                self.capacity *= 2;
                self._items = doubled_items;
            }

            self._items[self.length] = item;
            self.length += 1;
        }

        pub fn pop(self: *Self) !T {
            if (self.length <= 0)
                std.debug.panic(
                    "Array stack contains 0 elements. Ensure that something has been pushed onto the stack before attempting a pop operation.",
                    .{},
                );

            self.length -= 1;
            const top_val = self._items[self.length];
            self._items[self.length] = undefined;

            return top_val;
        }

        pub fn peek(self: Self) !T {
            if (self.length <= 0)
                std.debug.panic(
                    "Array stack contains 0 elements. Ensure that something has been pushed onto the stack before attempting a peek operation.",
                    .{},
                );

            return self._items[self.length - 1];
        }
    };
}

test "ArrayStack push and peek" {
    var stack = try ArrayStack([]const u8).init(testing.allocator, 5);
    defer stack.deinit();

    try stack.push("John");
    const val = try stack.peek();
    try testing.expectEqualStrings(val, "John");
}

test "ArrayStack pop and peek" {
    var stack = try ArrayStack([]const u8).init(testing.allocator, 5);
    defer stack.deinit();

    try stack.push("John");
    try stack.push("Doe");

    const popped = try stack.pop();
    try testing.expectEqual(popped, "Doe");

    const peeked = try stack.peek();
    try testing.expectEqual(peeked, "John");
}
