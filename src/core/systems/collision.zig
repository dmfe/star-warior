const std = @import("std");
const common = @import("common");

const Random = common.Random;
const Player = @import("../entities/player.zig");
const Enemy = @import("../entities/enemy.zig");
const Explosion = @import("../entities/explosion.zig");
const Projectile = @import("../entities/projectile.zig");
const Statistics = @import("../statistics.zig");

pub const Result = struct {
    player_died: bool = false,
};

pub fn update(
    allocator: std.mem.Allocator,
    random: *Random,
    player: *Player,
    enemies: []Enemy,
    projectiles: []Projectile,
    explosions: *std.ArrayList(Explosion),
    statistics: *Statistics,
) !Result {
    var result: Result = .{};

    for (enemies) |e|
        if (player.body.is_collided(&e.body)) {
            result.player_died = true;
            break;
        };

    for (enemies) |*e| {
        for (projectiles) |*p| {
            if (p.body.is_collided(&e.body) and !e.destroyed) {
                try explosions.append(
                    allocator,
                    Explosion.init(
                        random,
                        e.body.position,
                        e.body.size,
                        e.body.color,
                    ),
                );

                p.destroyed = true;
                e.destroyed = true;
                statistics.addScore(e.score_value);
            }
        }
    }

    return result;
}

