const std = @import("std");
const Base64 = @import("base64.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} belong to us.\n", .{"codebases"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    const b64 = Base64.init();
    const strs = [_][]const u8{ "Yo, Straing!", "Yo Straing!", "Yo Straing" };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var aa = std.heap.ArenaAllocator.init(gpa.allocator());
    defer aa.deinit();

    const allocator = aa.allocator();
    var enc_strs: [strs.len][]const u8 = undefined;
    for (0..enc_strs.len) |i| {
        enc_strs[i] = try b64.encode(allocator, strs[i]);
    }
    var dec_strs: [strs.len][]const u8 = undefined;
    for (0..dec_strs.len) |i| {
        dec_strs[i] = try b64.decode(allocator, enc_strs[i]);
    }

    for (strs, enc_strs, dec_strs) |s, e, d|
        try stdout.print("\nInputs: {s}\nEncoded: {s}\nDecoded: {s}\n", .{ s, e, d });

    try stdout.flush(); // Don't forget to flush!
}
