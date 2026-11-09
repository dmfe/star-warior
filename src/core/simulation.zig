const std = @import("std");
const common = @import("common");
const Random = common.Random;
const Color = common.Color;
const Vec2 = common.Vec2;
const Phase = @import("phase.zig").Phase;
const Input = @import("input.zig");
const Statistics = @import("statistics.zig");
const EnemySpawner = @import("spawning/enemy_spawner.zig");
const EnemyParams = @import("spawning/enemy_params.zig");
const Player = @import("entities/player.zig");
const Enemy = @import("entities/enemy.zig");
const Projectile = @import("entities/projectile.zig");
const platform = @import("platform");
const render = @import("render.zig");
const movement = @import("systems/movement.zig");
const shooting = @import("systems/shooting.zig");
const collision = @import("systems/collision.zig");
const cleanup = @import("systems/cleanup.zig");
const storage = @import("systems/storage.zig");

const Self = @This();
allocator: std.mem.Allocator,
random: Random,
phase: Phase,
player: Player,
enemies: std.ArrayList(Enemy),
projectiles: std.ArrayList(Projectile),
enemy_spawner: EnemySpawner,
statistics: Statistics,

pub fn init(
    allocator: std.mem.Allocator,
    random: Random,
) !Self {
    const screen_size: Vec2 = .{
        .x = platform.screenWidth(),
        .y = platform.screenHeight(),
    };
    const current_time = platform.getTime();
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
        current_time,
    );
    errdefer enemy_spawner.deinit(allocator);

    const player = Player.init(.{
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
        .next_activation_time = current_time - 0.1,
    });

    const max_score = storage.loadMaxScore();

    return .{
        .allocator = allocator,
        .random = random,
        .phase = .active,
        .player = player,
        .enemies = .empty,
        .projectiles = .empty,
        .enemy_spawner = enemy_spawner,
        .statistics = .{ .max_score = max_score },
    };
}

pub fn deinit(self: *Self) void {
    storage.saveMaxScore(self.statistics.max_score);
    self.enemy_spawner.deinit(self.allocator);
    self.enemies.deinit(self.allocator);
    self.projectiles.deinit(self.allocator);
}

pub fn update(self: *Self) !void {
    const input = Input.poll();
    switch (self.phase) {
        .active => try self.updateActive(input),
        .suspended => {},
        .finished => self.updateFinished(input),
    }
}

pub fn draw(self: *Self) !void {
    render.drawPlayer(&self.player);
    render.drawEnemies(self.enemies.items);
    render.drawProjectiles(self.projectiles.items);
    try render.drawFPS();
    try render.drawEnemiesCount(self.enemies.items);
    try render.drawStatistics(self.statistics);
    if (self.phase == .finished) {
        try render.drawSimulationIsOverText("GAME OVER");
    }
}

fn updateActive(self: *Self, input: Input) !void {
    const current_time = platform.getTime();
    const delta_time = platform.deltaTime();
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
        current_time,
    );
    try self.enemy_spawner.spawn(
        self.allocator,
        &self.random,
        &self.enemies,
        screen_size,
        current_time,
    );
    movement.updateEnemies(self.enemies.items, delta_time);
    movement.updateProjectiles(self.projectiles.items, delta_time);
    cleanup.update(&self.enemies, &self.projectiles, screen_size);
    collision.update(
        &self.player,
        self.enemies.items,
        self.projectiles.items,
        &self.statistics,
        &self.phase,
    );

    if (self.phase == .finished) storage.saveMaxScore(self.statistics.max_score);
}

fn updateFinished(self: *Self, input: Input) void {
    if (input.pressed.space) self.reset();
}

fn reset(self: *Self) void {
    const current_time = platform.getTime();
    const screen_width = platform.screenWidth();
    const screen_height = platform.screenHeight();

    self.player.body.position = .{
        .x = screen_width / 2.0,
        .y = screen_height / 2.0,
    };
    self.player.weapon.next_activation_time = current_time - 0.1;

    self.enemies.clearRetainingCapacity();
    self.enemy_spawner.next_generation_time = current_time - 0.1;
    self.projectiles.clearRetainingCapacity();
    self.statistics.current_score = 0;
    self.phase = .active;
}

