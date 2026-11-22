const Body = @import("../entities/body.zig");
const Player = @import("../entities/player.zig");
const Enemy = @import("../entities/enemy.zig");
const Projectile = @import("../entities/projectile.zig");
const Statistics = @import("../statistics.zig");

pub const Result = struct {
    player_died: bool = false,
};

pub fn update(
    player: *Player,
    enemies: []Enemy,
    projectiles: []Projectile,
    statistics: *Statistics,
) Result {
    var result: Result = .{};

    for (enemies) |e|
        if (player.body.is_collided(&e.body)) {
            result.player_died = true;
            break;
        };
    for (enemies) |*e|
        for (projectiles) |*p|
            if (p.body.is_collided(&e.body) and !e.destroyed) {
                p.destroyed = true;
                e.destroyed = true;
                statistics.addScore(e.score_value);
            };

    return result;
}

