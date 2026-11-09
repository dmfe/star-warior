const std = @import("std");
const Input = @import("../input.zig");
const Player = @import("../entities/player.zig");
const Projectile = @import("../entities/projectile.zig");

pub fn update(
    allocator: std.mem.Allocator,
    player: *Player,
    projectiles: *std.ArrayList(Projectile),
    input: Input,
    current_time: f64,
) !void {
    const weapon = &player.weapon;
    if (input.pressed.space and weapon.canActivate(current_time)) {
        const projectile: Projectile =  .{
            .body = .{
                .position = .{
                    .x = player.body.position.x, 
                    .y = player.body.position.y - player.body.size / 2.0,
                },
                .size = weapon.projectile_size,
                .speed = weapon.projectile_speed,
                .color = weapon.projectile_color,
            },
        };
        try projectiles.append(allocator, projectile);
        weapon.updateActivation(current_time);
    }
}

