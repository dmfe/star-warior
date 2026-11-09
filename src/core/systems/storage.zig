const std = @import("std");
const platform = @import("platform");

pub fn saveMaxScore(max_score: u64) void {
    platform.saveMaxScore(max_score) catch |err| {
        std.log.warn("Could not save maximum score: {}", .{ err });
    };
}

pub fn loadMaxScore() u64 {
    return platform.loadMaxScore() catch |err| blk: {
        std.log.warn("Could not load maximum score: {}", . { err });
        break :blk 0;
    };
}
