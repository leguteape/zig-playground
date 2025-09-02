const std = @import("std");
const net = std.net;
const posix = std.posix;

pub const Socket = @This();

_address: net.Address,
_stream: net.Stream,

pub fn init(host: [4]u8, port: u16) !Socket {
    const addr = net.Address.initIp4(host, port);
    const socket = try posix.socket(
        addr.any.family,
        posix.SOCK.STREAM,
        posix.IPPROTO.TCP,
    );
    const stream = net.Stream{ .handle = socket };

    return Socket{ ._address = addr, ._stream = stream };
}

pub fn listen(self: Socket, opts: net.Address.ListenOptions) !net.Server {
    return try self._address.listen(opts);
}
