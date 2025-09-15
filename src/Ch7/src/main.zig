const std = @import("std");

const Request = @import("request.zig");
const Response = @import("response.zig");
const Socket = @import("socket.zig");

pub fn main() !void {
    const socket = try Socket.init([4]u8{ 127, 0, 0, 1 }, 4090);
    var server = try socket.listen(.{});
    const connection = try server.accept();

    var buffer: [1024]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }

    const request = try Request.init(connection, &buffer);
    std.debug.print("Request:\n{any}\n", .{request});

    const response = Response.init(request);
    std.debug.print("\nResponse:\n{any}\n", .{response});

    try response.format_and_write(connection);
    std.debug.print("\nDone!\n", .{});
}
