const std = @import("std");
const common = @import("common");
const platform = @import("platform");

const Random = common.Random;
const Color = common.Color;
const Vec2 = common.Vec2;

const Input = @import("input.zig");
const Statistics = @import("statistics.zig");
const Event = @import("simulation_event.zig").Event;
const SimulationContext = @import("simulation_context.zig").Context;
const SimulationView = @import("simulation_view.zig").SimulationView;

const EnemySpawner = @import("spawning/enemy_spawner.zig");
const EnemyParams = @import("spawning/enemy_params.zig");

const Player = @import("entities/player.zig");
const Enemy = @import("entities/enemy.zig");
const Projectile = @import("entities/projectile.zig");
const Explosion = @import("entities/explosion.zig");

const movement = @import("systems/movement.zig");
const shooting = @import("systems/shooting.zig");
const collision = @import("systems/collision.zig");
const explosion_system = @import("systems/explosions.zig");
const cleanup = @import("systems/cleanup.zig");

const Self = @This();
allocator: std.mem.Allocator,
random: Random,
player: Player,
enemies: std.ArrayList(Enemy),
projectiles: std.ArrayList(Projectile),
explosions: std.ArrayList(Explosion),
enemy_spawner: EnemySpawner,
simulation_time: f64,

pub fn init(
    allocator: std.mem.Allocator,
    random: Random,
) !Self {
    const screen_size: Vec2 = .{
        .x = platform.screenWidth(),
        .y = platform.screenHeight(),
    };
    const simulation_time: f64 = 0.0;
    const enemy_colors = [_]Color{
        .red,
        .blue,
        .green,
        .orange,
        .purple,
        .gold,
    };
    const enemy_params: EnemyParams = .{
        .generation_chance = 85,
        .generation_cooldown = 0.3,
        .min_size = 16.0,
        .max_size = 64.0,
        .min_speed = 50.0,
        .max_speed = 150.0,
    };
    const enemy_spawner = try EnemySpawner.init(
        allocator,
        enemy_params,
        enemy_colors[0..],
        simulation_time,
    );
    errdefer enemy_spawner.deinit(allocator);

    var player = Player.init(.{
        .position = .{
            .x = screen_size.x / 2.0,
            .y = screen_size.y / 2.0,
        },
        .size = 32.0,
        .speed = 400.0,
        .color = .yellow,
    }, .{
        .projectile_size = 5.0,
        .projectile_speed = 800.0,
        .projectile_color = .green,
        .cooldown = 0.1,
        .next_activation_time = simulation_time - 0.1,
    });
    // testing inventory
    _ = player.inventory.add(.{
        .kind = .health,
        .count = 2,
    });
    _ = player.inventory.add(.{
        .kind = .shield,
    });
    // testing inventory

    return .{
        .allocator = allocator,
        .random = random,
        .player = player,
        .enemies = .empty,
        .projectiles = .empty,
        .explosions = .empty,
        .enemy_spawner = enemy_spawner,
        .simulation_time = simulation_time,
    };
}

pub fn deinit(self: *Self) void {
    self.enemy_spawner.deinit(self.allocator);
    self.enemies.deinit(self.allocator);
    self.projectiles.deinit(self.allocator);
    self.explosions.deinit(self.allocator);
}

pub fn update(
    self: *Self,
    input: Input,
    delta_time: f32,
    context: *SimulationContext,
) !Event {
    self.simulation_time += @as(f64, delta_time);

    const screen_size: Vec2 = .{
        .x = platform.screenWidth(),
        .y = platform.screenHeight(),
    };

    movement.updatePlayer(&self.player, input, screen_size, delta_time);
    try shooting.update(
        self.allocator,
        &self.player,
        &self.projectiles,
        input,
        self.simulation_time,
    );
    try self.enemy_spawner.spawn(
        self.allocator,
        &self.random,
        &self.enemies,
        screen_size,
        self.simulation_time,
    );
    movement.updateEnemies(self.enemies.items, delta_time);
    movement.updateProjectiles(self.projectiles.items, delta_time);
    explosion_system.update(self.explosions.items, delta_time);
    const collision_result = try collision.update(
        self.allocator,
        &self.random,
        &self.player,
        self.enemies.items,
        self.projectiles.items,
        &self.explosions,
        context.statistics,
    );

    cleanup.update(
        &self.enemies,
        &self.projectiles,
        &self.explosions,
        screen_size
    );

    if (collision_result.player_died)
        return .player_died;

    return .none;
}

pub fn view(self: *const Self) SimulationView {
    return .{
        .player = &self.player,
        .enemies = self.enemies.items,
        .projectiles = self.projectiles.items,
        .explosions = self.explosions.items,
    };
}

pub fn useInventoryItem(
    self: *Self,
    slot_index: usize,
) void {
    const item_kind = self.player.inventory.consume(slot_index) orelse
        return;

    switch (item_kind) {
        .health => {
            // TODO
        },
        .shield => {
            // TODO
        },
        .rapid_fire => {
            // TODO
        },
    }
}

pub fn reset(
    self: *Self,
    context: *SimulationContext,
) void {
    const screen_width = platform.screenWidth();
    const screen_height = platform.screenHeight();

    self.simulation_time = 0.0;
    self.player.body.position = .{
        .x = screen_width / 2.0,
        .y = screen_height / 2.0,
    };
    self.player.weapon.next_activation_time = self.simulation_time - 0.1;
    self.enemies.clearRetainingCapacity();
    self.enemy_spawner.next_generation_time = self.simulation_time - 0.1;
    self.projectiles.clearRetainingCapacity();
    context.statistics.current_score = 0;
}

