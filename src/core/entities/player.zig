const Body = @import("body.zig");
const Weapon = @import("weapon.zig");
const Input = @import("../input.zig");

const Self = @This();
body: Body,
weapon: Weapon,

pub fn init(body: Body, weapon: Weapon) Self {
    return .{
        .body = body,
        .weapon = weapon,
    };
}

pub fn update(self: *Self, input: Input, delta_time: f32) void {
    const speed = self.body.speed;
    if (input.down.right) self.body.position.x += speed * delta_time;
    if (input.down.left) self.body.position.x -= speed * delta_time;
    if (input.down.down) self.body.position.y += speed * delta_time;
    if (input.down.up) self.body.position.y -= speed * delta_time;
}

