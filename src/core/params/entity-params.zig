const Color = @import("common").Color;
const ProjectileParams = @import("projectile-params.zig");

const Self = @This();
x: f32 = 0.0,
y: f32 = 0.0,
size: f32,
speed: f32,
color: Color,
projectile_params: ?ProjectileParams = null,

