const common = @import("common");
const Vec2 = common.Vec2;
const Color = common.Color;

const Self = @This();
position: Vec2,
size: f32,
speed: f32,
color: Color,

pub fn is_collided(self: *const Self, other: *const Self) bool {
    const self_pos = self.position;
    const other_pos = other.position;
    const x_collided = @abs(self_pos.x - other_pos.x) <= (self.size + other.size) / 2.0;
    const y_collided = @abs(self_pos.y - other_pos.y) <= (self.size + other.size) / 2.0;
    return x_collided and y_collided;
}

