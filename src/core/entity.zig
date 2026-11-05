const std = @import("std");
const Color = @import("common").Color;
const Weapon = @import("weapon.zig");
const ProjectileParams = @import("params/projectile-params.zig");
const EntityParams = @import("params/entity-params.zig");

const Self = @This();
x: f32,
y: f32,
size: f32,
speed: f32,
color: Color,
collided: bool = false,
weapon: ?*Weapon = null,
allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator, params: EntityParams) !*Self {
    const entity_ptr = try allocator.create(Self);
    errdefer allocator.destroy(entity_ptr);

    const weapon_ptr: ?*Weapon =
        if (params.projectile_params) |prj_params| blk: {
            const weapon_ptr = try allocator.create(Weapon);
            errdefer allocator.destroy(weapon_ptr);
            weapon_ptr.* = .{
                .size = prj_params.size,
                .speed = prj_params.speed,
                .reload_time = prj_params.reload_time,
                .last_shot_time = -prj_params.reload_time,
                .color = prj_params.color,
            };
            break :blk weapon_ptr;
        } else blk: {
            break :blk null;
        };

    entity_ptr.* = .{
        .x = params.x,
        .y = params.y, 
        .size = params.size,
        .speed = params.speed,
        .color = params.color,
        .weapon = weapon_ptr,
        .allocator = allocator,
    };
    return entity_ptr;
}

pub fn setWeapon(self: *Self, projectile_params: ProjectileParams) !void {
    if (self.weapon) |weapon| self.allocator.destroy(weapon);
    const weapon_ptr = try self.allocator.create(Weapon);
    errdefer self.allocator.destroy(weapon_ptr);
    weapon_ptr.* = .{
        .size = projectile_params.size,
        .speed = projectile_params.speed,
        .reload_time = projectile_params.reload_time,
        .last_shot_time = -projectile_params.reload_time,
        .color = projectile_params.color,
    };
    self.weapon = weapon_ptr;
}

pub fn deinit(self: *Self) void {
    if (self.weapon) |weapon| self.allocator.destroy(weapon);
    self.allocator.destroy(self);
}

pub fn is_collided(self: *Self, other: *const Self) bool {
    const x_collided = @abs(self.x - other.x) <= (self.size + other.size) / 2.0;
    const y_collided = @abs(self.y - other.y) <= (self.size + other.size) / 2.0;
    return x_collided and y_collided;
}

