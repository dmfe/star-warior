const std = @import("std");
const Entity = @import("entity.zig");
const EntityParams = @import("params/entity-params.zig");
const EntityRandomParams = @import("params/entity-random-params.zig");

const Self = @This();
controllable: *Entity,
entities: std.ArrayList(*Entity),
projectiles: std.ArrayList(*Entity),
entity_random_params: *EntityRandomParams,
running: bool,
allocator: std.mem.Allocator,

pub fn init(
    allocator: std.mem.Allocator,
    entity_params: EntityParams,
    entity_random_params: EntityRandomParams,
) !*Self {
    const state_ptr = try allocator.create(Self);
    errdefer allocator.destroy(state_ptr);
    
    const controllable_ptr = try Entity.init(allocator, entity_params);
    errdefer controllable_ptr.deinit();

    const entity_random_params_ptr = try allocator.create(EntityRandomParams);
    errdefer allocator.destroy(entity_random_params);
    entity_random_params_ptr.* = entity_random_params;

    state_ptr.* = .{
        .controllable = controllable_ptr,
        .entities = .empty,
        .projectiles = .empty,
        .entity_random_params = entity_random_params_ptr,
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

    self.allocator.destroy(self.entity_random_params);

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

    for (self.entities.items) |e| e.deinit();
    self.entities.clearRetainingCapacity();

    for (self.projectiles.items) |p| p.deinit();
    self.projectiles.clearRetainingCapacity();

    self.running = true;
}

