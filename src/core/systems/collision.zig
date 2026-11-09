const Body = @import("../entities/body.zig");
const Player = @import("../entities/player.zig");
const Enemy = @import("../entities/enemy.zig");
const Projectile = @import("../entities/projectile.zig");
const Statistics = @import("../statistics.zig");
const Phase = @import("../phase.zig").Phase;

pub fn update(
    player: *Player,
    enemies: []Enemy,
    projectiles: []Projectile,
    statistics: *Statistics,
    phase: *Phase,
) void {
    for (enemies) |e|
        if (player.body.is_collided(&e.body)) {
            phase.* = .finished;
            break;
        };
    for (enemies) |*e|
        for (projectiles) |*p|
            if (p.body.is_collided(&e.body) and !e.destroyed) {
                p.destroyed = true;
                e.destroyed = true;
                statistics.addScore(e.score_value);
            };
}

