const Explosion = @import("../entities/explosion.zig");

pub fn update(
    explosions: []Explosion,
    delta_time: f32,
) void {
    for (explosions) |*explosion|
        explosion.update(delta_time);
}

