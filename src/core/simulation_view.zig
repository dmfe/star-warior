const Player = @import("entities/player.zig");
const Enemy = @import("entities/enemy.zig");
const Projectile = @import("entities/projectile.zig");

pub const SimulationView = struct {
    player: *const Player,
    enemies: []const Enemy,
    projectiles: []const Projectile,
};

