const std = @import("std");
const Entity = @import("entity.zig");
const Input = @import("input.zig");
const common = @import("common");
const Random = common.Random;
const Color = common.Color;

pub fn updateControllable(controllable: *Entity, input: Input, delta_time: f32) void {
    if (input.right) controllable.x += controllable.speed * delta_time;
    if (input.left) controllable.x -= controllable.speed * delta_time;
    if (input.down) controllable.y += controllable.speed * delta_time;
    if (input.up) controllable.y -= controllable.speed * delta_time;
}

pub fn clampEntityToScreen(entity: *Entity, screen_w: f32, screen_h: f32) void {
    entity.x = std.math.clamp(entity.x, entity.size, screen_w - entity.size);
    entity.y = std.math.clamp(entity.y, entity.size, screen_h - entity.size);
}

pub fn updateEntities(entities: []Entity, delta_time: f32) void {
    for (entities) |*e|
        e.y += e.speed * delta_time;
}

pub const EntitiesParams = struct {
    generation_chance: u8,
    min_size: f32,
    max_size: f32,
    min_speed: f32,
    max_speed: f32,
    colors: []const Color,
};

pub fn generateRandomEntities(
    random: *Random,
    allocator: std.mem.Allocator,
    entities: *std.ArrayList(Entity),
    params: EntitiesParams,
    screen_w: f32,
) !void {
    if (random.intRangeAtMost(0, 99) >= params.generation_chance) {
        const size = random.genFloatRange(params.min_size, params.max_size);
        try entities.append(allocator, .{
            .x = random.genFloatRange(size / 2.0, screen_w - size / 2.0),
            .y = -size,
            .size = size,
            .speed = random.genFloatRange(params.min_speed, params.max_speed),
            .color = random.randomColor(params.colors),
        });
    }
}

pub fn removeOffscreenEntities(entities: *std.ArrayList(Entity), screen_h: f32) void {
    var i: usize = entities.items.len;
    while (i > 0) {
        i -= 1;
        if (entities.items[i].y > screen_h + entities.items[i].size) {
            _ = entities.swapRemove(i);
        }
    }
}

pub fn collidedWithEntities(
    controllable: *Entity,
    entities: []const Entity
) bool {
    for (entities) |*e|
        if (controllable.is_collided(e))
            return true;

    return false;
}

