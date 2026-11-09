const std = @import("std");
const rl = @import("raylib");

const score_file = "max_score.txt";

pub fn loadMaxScore() !u64 {
    const data = rl.loadFileData(score_file) catch |err| switch (err) {
        error.LoadFileData => return 0,
    };
    defer rl.unloadFileData(data);

    const text = std.mem.trim(u8, data, " \r\n\t");
    if (text.len == 0) return 0;

    return std.fmt.parseInt(u64, text, 10) catch 0;
}

pub fn saveMaxScore(score: u64) !void {
    var buffer: [32]u8 = undefined;
    const text = try std.fmt.bufPrint(&buffer, "{d}\n", .{ score });

    if (!rl.saveFileData(score_file, text)) {
        return error.SaveMaxScoreFailed;
    }
}

