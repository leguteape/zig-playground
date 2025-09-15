const std = @import("std");

const Request = @import("request.zig");

pub const Response = @This();

version: []const u8,
status_code: u16,
status_message: []const u8,
content_type: []const u8,
body: []const u8,

pub fn init(request: Request) Response {
    switch (request.method) {
        .GET => {
            if (std.mem.eql(u8, request.uri, "/"))
                return Response{
                    .version = request.version,
                    .status_code = 200,
                    .status_message = "OK",
                    .content_type = "text/html",
                    .body = "<html><body><h1>Hello, World!</h1></body></html>",
                }
            else
                return Response{
                    .version = request.version,
                    .status_code = 404,
                    .status_message = "Not Found",
                    .content_type = "text/html",
                    .body = "<html><body><h1>File Not Found!</h1></body></html>",
                };
        },
    }
}

pub fn format_and_write(self: Response, conn: std.net.Server.Connection) !void {
    const res_template =
        \\{s} {d} {s}
        \\Content-Length: {d}
        \\Content-Type: {s}
        \\Connection: Closed
        \\
        \\{s}
    ;

    var stream_buffer: [1024]u8 = undefined;
    var stream_writer = conn.stream.writer(&stream_buffer);
    const stream = &stream_writer.interface;

    try stream.print(res_template, .{
        self.version,
        self.status_code,
        self.status_message,
        self.body.len,
        self.content_type,
        self.body,
    });

    try stream.flush();
}
