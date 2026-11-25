const std = @import("std");
const core = @import("core");
const platform = @import("platform");
const resources_module = @import("resources");

const SimulationView = core.SimulationView;
const Player = core.Player;
const Enemy = core.Enemy;
const Projectile = core.Projectile;
const Explosion = core.Explosion;

const ResourceManager = resources_module.ResourceManager;

const Self = @This();

pub fn init(
    resources: *const ResourceManager,
) Self {
    const shaders_count = resources.shaders.count();
    std.log.info("Init simulation renderer. Shaders loaded: {}", .{shaders_count});
    return .{};
}

pub fn draw(
    self: *const Self,
    resources: *ResourceManager,
    view: SimulationView,
) void {
    _ = self;
    _ = resources;
    drawPlayer(view.player);
    drawEnemies(view.enemies);
    drawProjectiles(view.projectiles);
    drawExplosions(view.explosions);
}

fn drawPlayer(
    player: *const Player,
) void {
    const body = player.body;
    platform.drawCircle(
        body.position.x,
        body.position.y,
        body.size / 2.0,
        body.color
    );
}

fn drawEnemies(
    enemies: []const Enemy,
) void {
    for (enemies) |e|
        platform.drawRect(
            e.body.position.x - e.body.size / 2.0,
            e.body.position.y - e.body.size / 2.0, 
            e.body.size,
            e.body.size,
            e.body.color
        );
}

fn drawProjectiles(
    projectiles: []const Projectile,
) void {
    for (projectiles) |p|
        platform.drawRect(
            p.body.position.x - p.body.size / 2.0,
            p.body.position.y - p.body.size / 2.0, 
            p.body.size,
            p.body.size,
            p.body.color
        );
}

fn drawExplosions(
    explosions: []const Explosion,
) void {
    for (explosions) |explosion| {
        for (explosion.particles[0..explosion.particle_count]) |particle| {
            if (particle.expired())
                continue;

            var color = particle.color;
            const remaining = 1.0 - particle.progress();
            color.a = @intFromFloat(255.0 * remaining);

            platform.drawCircle(
                particle.position.x,
                particle.position.y,
                particle.radius,
                color,
            );
        }
    }
}

