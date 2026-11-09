const std = @import("std");
const Vec2 = @import("common").Vec2;
const Input = @import("../input.zig");
const Player = @import("../entities/player.zig");
const Enemy = @import("../entities/enemy.zig");
const Projectile = @import("../entities/projectile.zig");

pub fn updatePlayer(player: *Player, input: Input, screen_size: Vec2, dt: f32) void {
    player.update(input, dt);
    const cur_pos = player.body.position;
    const size = player.body.size;
    player.body.position = .{
        .x = std.math.clamp(cur_pos.x, size / 2.0, screen_size.x - size / 2.0),
        .y = std.math.clamp(cur_pos.y, size / 2.0, screen_size.y - size / 2.0),
    };
}

pub fn updateEnemies(enemies: []Enemy, dt: f32) void {
    for (enemies) |*enemy| enemy.update(dt);
}

pub fn updateProjectiles(projectiles: []Projectile, dt:f32) void {
    for (projectiles) |*projectile| projectile.update(dt);
}

