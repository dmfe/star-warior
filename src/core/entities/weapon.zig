const Color = @import("common").Color;

const Self = @This();
projectile_size: f32,
projectile_speed: f32,
projectile_color: Color,
cooldown: f64,
next_activation_time: f64,

pub fn canActivate(self: *const Self, current_time: f64) bool {
    return current_time > self.next_activation_time;
}

pub fn updateActivation(self: *Self, current_time: f64) void {
    self.next_activation_time = current_time + self.cooldown;
}

