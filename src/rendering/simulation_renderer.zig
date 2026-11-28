const core = @import("core");
const platform = @import("platform");
const resources_module = @import("resources");

const SimulationView = core.SimulationView;
const Enemy = core.Enemy;
const Projectile = core.Projectile;
const Explosion = core.Explosion;

const ResourceManager = resources_module.ResourceManager;

const PlayerRenderer = @import("player_renderer.zig");

const Self = @This();
player_renderer: PlayerRenderer,

pub fn init(
    resources: *const ResourceManager,
) !Self {
    return .{
        .player_renderer = try PlayerRenderer.init(resources),
    };
}

pub fn update(
    self: *Self,
    delta_time: f32
) void {
    self.player_renderer.update(delta_time);
}

pub fn draw(
    self: *const Self,
    resources: *const ResourceManager,
    view: SimulationView,
) void {
    self.player_renderer.draw(
        resources,
        view.player,
    );
    drawEnemies(view.enemies);
    drawProjectiles(view.projectiles);
    drawExplosions(view.explosions);
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

