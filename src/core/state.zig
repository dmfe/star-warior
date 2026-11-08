const std = @import("std");
const Color = @import("common").Color;
const Entity = @import("entity.zig");
const EntityParams = @import("params/entity-params.zig");
const EnemyParams = @import("params/enemy-params.zig");

const Self = @This();
controllable: *Entity,
entities: std.ArrayList(*Entity),
projectiles: std.ArrayList(*Entity),
enemy_params: *EnemyParams,
enemy_last_generation_time: f64,
running: bool,
allocator: std.mem.Allocator,

pub fn init(
    allocator: std.mem.Allocator,
    entity_params: EntityParams,
    enemy_params: EnemyParams,
) !*Self {
    const state_ptr = try allocator.create(Self);
    errdefer allocator.destroy(state_ptr);
    
    const controllable_ptr = try Entity.init(allocator, entity_params);
    errdefer controllable_ptr.deinit();

    const enemy_params_ptr = try allocator.create(EnemyParams);
    errdefer allocator.destroy(enemy_params_ptr);
    const owned_colors = try allocator.dupe(
        Color,
        enemy_params.colors,
    );
    errdefer allocator.free(owned_colors);
    enemy_params_ptr.* = .{
        .generation_chance = enemy_params.generation_chance,
        .generation_cooldown = enemy_params.generation_cooldown,
        .min_size = enemy_params.min_size,
        .max_size = enemy_params.max_size,
        .min_speed = enemy_params.min_speed,
        .max_speed = enemy_params.max_speed,
        .colors = owned_colors,
    };

    state_ptr.* = .{
        .controllable = controllable_ptr,
        .entities = .empty,
        .projectiles = .empty,
        .enemy_params = enemy_params_ptr,
        .enemy_last_generation_time = -enemy_params_ptr.generation_cooldown,
        .running = true,
        .allocator = allocator,
    };
    return state_ptr;
}

pub fn deinit(self: *Self) void {
    self.controllable.deinit();

    for (self.entities.items) |e| e.deinit();
    self.entities.deinit(self.allocator);

    for (self.projectiles.items) |p| p.deinit();
    self.projectiles.deinit(self.allocator);

    self.allocator.free(self.enemy_params.colors);
    self.allocator.destroy(self.enemy_params);

    self.allocator.destroy(self);
}

pub fn addEntity(self: *Self, entityParams: EntityParams) !void {
    var entity_ptr = try Entity.init(self.allocator, entityParams);
    errdefer entity_ptr.deinit();
    try self.entities.append(self.allocator, entity_ptr);
}

pub fn addProjectile(self: *Self, entityParams: EntityParams) !void {
    const projectile_ptr = try Entity.init(self.allocator, entityParams);
    errdefer projectile_ptr.deinit();
    try self.projectiles.append(self.allocator, projectile_ptr);
}

pub fn is_running(self: *const Self) bool {
    return self.running;
}

pub fn reset(self: *Self, start_x: f32, start_y: f32) void {
    self.controllable.x = start_x;
    self.controllable.y = start_y;
    self.enemy_last_generation_time = -self.enemy_params.generation_cooldown;
    self.running = true;

    for (self.entities.items) |e| e.deinit();
    self.entities.clearRetainingCapacity();

    for (self.projectiles.items) |p| p.deinit();
    self.projectiles.clearRetainingCapacity();
}

