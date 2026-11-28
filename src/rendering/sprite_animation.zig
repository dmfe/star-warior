const std = @import("std");

const Self = @This();
frame: u32 = 0,
elapsed: f32 = 0.0,
frame_duration: f32 = 0.12,

pub fn update(
    self: *Self,
    delta_time: f32,
    frame_count: u32,
) void {
    std.debug.assert(frame_count > 0);
    std.debug.assert(self.frame_duration > 0.0);

    self.elapsed += delta_time;
    while (self.elapsed >= self.frame_duration) {
        self.elapsed -= self.frame_duration;
        self.frame = (self.frame + 1) % frame_count;
    }
}

