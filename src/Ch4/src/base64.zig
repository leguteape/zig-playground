const std = @import("std");
const Allocator = std.mem.Allocator;
const Base64 = @This();

_table: []const u8 = undefined,

pub fn init() Base64 {
    const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const lower = "abcdefghijklmnopqrstuvwxyz";
    const digits = "0123456789";
    const syms = "+/";

    return Base64{ ._table = upper ++ lower ++ digits ++ syms };
}

pub fn encode(self: Base64, allocator: Allocator, input: []const u8) ![]u8 {
    var buffer = [3]u8{ 0, 0, 0 };
    var buf_count: u8 = 0;
    const output = try allocator.alloc(u8, try _compute_encoded_size(input));
    var iout: usize = 0;

    for (input) |inp| {
        buffer[buf_count] = inp;
        buf_count += 1;

        if (buf_count == 3) {
            output[iout] = self._char_at(buffer[0] >> 2);
            output[iout + 1] = self._char_at(((buffer[0] & 0x03) << 4) + (buffer[1] >> 4));
            output[iout + 2] = self._char_at(((buffer[1] & 0x0F) << 2) + (buffer[2] >> 6));
            output[iout + 3] = self._char_at(buffer[2] & 0x3F);
            iout += 4;
            buf_count = 0;
        }
    }

    if (buf_count == 2) {
        output[iout] = self._char_at(buffer[0] >> 2);
        output[iout + 1] = self._char_at(((buffer[0] & 0x03) << 4) + (buffer[1] >> 4));
        output[iout + 2] = self._char_at((buffer[1] & 0x0F) << 2);
        output[iout + 3] = '=';
    } else if (buf_count == 1) {
        output[iout] = self._char_at(buffer[0] >> 2);
        output[iout + 1] = self._char_at((buffer[0] & 0x03) << 4);
        output[iout + 2] = '=';
        output[iout + 3] = '=';
    }

    return output;
}

pub fn decode(self: Base64, allocator: Allocator, input: []const u8) ![]u8 {
    if (input.len == 0)
        return "";

    var buffer = [4]u8{ 0, 0, 0, 0 };
    var buf_count: u8 = 0;
    const output = try allocator.alloc(u8, try _compute_decoded_size(input));
    var iout: u8 = 0;

    for (input) |inp| {
        buffer[buf_count] = self._index_of(inp);
        buf_count += 1;

        if (buf_count == 4) {
            output[iout] = (buffer[0] << 2) + (buffer[1] >> 4);
            if (buffer[2] != 64)
                output[iout + 1] = (buffer[1] << 4) + (buffer[2] >> 2);
            if (buffer[3] != 64)
                output[iout + 2] = (buffer[2] << 6) + buffer[3];

            iout += 3;
            buf_count = 0;
        }
    }

    return output;
}

fn _char_at(self: Base64, index: usize) u8 {
    return self._table[index];
}

fn _index_of(self: Base64, char: u8) u8 {
    const unknown_idx = 64;

    if (char == '=') {
        return unknown_idx;
    }
    for (self._table, 0..) |ch, i| {
        if (char == ch)
            return @intCast(i);
    }
    return unknown_idx;
}

fn _compute_encoded_size(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }
    const n_groups = try std.math.divCeil(usize, input.len, 3);

    return n_groups * 4;
}

fn _compute_decoded_size(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }
    const n_groups = try std.math.divFloor(usize, input.len, 4);
    var decoded_size = n_groups * 3;

    var i = input.len - 1;
    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            decoded_size -= 1;
        } else {
            break;
        }
    }

    return decoded_size;
}
