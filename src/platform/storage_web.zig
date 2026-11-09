const std = @import("std");

extern fn star_warior_load_max_score(
    output: [*]u8,
    capacity: usize,
) i32;

extern fn star_warior_save_max_score(
    value: [*]const u8,
    length: usize,
) i32;

pub fn loadMaxScore() !u64 {
    var buffer: [32]u8 = undefined;

    const result = star_warior_load_max_score(
        &buffer,
        buffer.len,
    );

    if (result < 0) return error.LoadMaxScoreFailed;
    if (result == 0) return 0;

    const length: usize = @intCast(result);

    return std.fmt.parseInt(
        u64,
        buffer[0..length],
        10,
    ) catch 0;
}

pub fn saveMaxScore(score: u64) !void {
    var buffer: [32]u8 = undefined;
    const text = try std.fmt.bufPrint(&buffer, "{d}", .{ score });

    if (star_warior_save_max_score(text.ptr, text.len) != 0) {
        return error.SaveMaxScoreFailed;
    }
}

