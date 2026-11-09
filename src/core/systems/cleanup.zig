const std = @import("std");
const Vec2 = @import("common").Vec2;
const Enemy = @import("../entities/enemy.zig");
const Projectile = @import("../entities/projectile.zig");

pub fn update(
    enemies: *std.ArrayList(Enemy),
    projectiles: *std.ArrayList(Projectile),
    screen_size: Vec2,
) void {
    var i: usize = enemies.items.len;
    while (i > 0) {
        i -= 1;
        if (
            enemies.items[i].destroyed
            or enemies.items[i].body.position.y > screen_size.y + enemies.items[i].body.size
        ) {
            _ = enemies.swapRemove(i);
        }
    }
    i = projectiles.items.len;
    while (i > 0) {
        i -= 1;
        if (
            projectiles.items[i].destroyed
            or projectiles.items[i].body.position.y < 0.0 - projectiles.items[i].body.size / 2.0
        ) {
            _ = projectiles.swapRemove(i);
        }
    }
}

