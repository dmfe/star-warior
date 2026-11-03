const std = @import("std");
const Color = @import("color.zig");

const Self = @This();
prng: std.Random.DefaultPrng,

pub fn init() Self {
    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();
    const timestamp = std.Io.Clock.now(.real, io);
    const seed: u64 = @intCast(timestamp.toNanoseconds());
    var prng = std.Random.DefaultPrng.init(seed);
    _ = prng.random();

    return .{
        .prng = prng,
    };
}

pub fn genFloatRange(self: *Self, at: f32, most: f32) f32 {
    var rand = self.prng.random();
    return at + rand.float(f32) * (most - at);
}

pub fn randomColor(self: *Self, colors: []const Color) Color {
    var rand = self.prng.random();
    return colors[rand.uintLessThan(usize, colors.len)];
}

pub fn intRangeAtMost(self: *Self, at: u8, most: u8) u8 {
    var rand = self.prng.random();
    return rand.intRangeAtMost(u8, at, most);
}

