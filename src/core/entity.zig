const Color = @import("common").Color;

const Self = @This();
x: f32,
y: f32,
size: f32,
speed: f32,
color: Color,

pub fn is_collided(self: *Self, other: *const Self) bool {
    const x_collided = @abs(self.x - other.x) <= (self.size + other.size) / 2.0;
    const y_collided = @abs(self.y - other.y) <= (self.size + other.size) / 2.0;
    return x_collided and y_collided;
}

