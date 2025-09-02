const std = @import("std");

pub const Request = @This();

method: RequestMethod,
uri: []const u8,
version: []const u8,

pub fn init(conn: std.net.Server.Connection, buffer: []u8) !Request {
    const reader = conn.stream.reader();
    _ = try reader.read(buffer);
    var req_lines = std.mem.splitScalar(u8, buffer, '\n');
    const first_line = req_lines.next().?;
    var fl_iter = std.mem.splitScalar(u8, first_line, ' ');

    return Request{
        .method = try RequestMethod.init(fl_iter.next().?),
        .uri = fl_iter.next().?,
        .version = fl_iter.next().?,
    };
}

const RequestMethod = enum {
    GET,

    pub fn init(method: []const u8) !RequestMethod {
        return method_map.get(method).?;
    }

    pub fn is_available(method: []const u8) bool {
        if (method_map.get(method)) |_| {
            return true;
        }
        return false;
    }
};

const method_map = std.StaticStringMap(RequestMethod).initComptime(.{
    .{ "GET", RequestMethod.GET },
});
