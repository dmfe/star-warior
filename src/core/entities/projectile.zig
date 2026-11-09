const Body = @import("body.zig");

const Self = @This();
body: Body,
damage: u32 = 1,
destroyed: bool = false,

pub fn update(self: *Self, delta_time: f32) void {
    self.body.position.y -= self.body.speed * delta_time;
}

