const std = @import("std");
const platform = @import("platform");
const State = @import("state.zig");
const Input = @import("input.zig");
const Random = @import("common").Random;
const EntityParams = @import("params/entity-params.zig");

pub fn updateControllable(state: *State, input: Input, delta_time: f32) void {
    const speed = state.controllable.speed;
    if (input.down.right) state.controllable.x +=speed * delta_time;
    if (input.down.left) state.controllable.x -= speed * delta_time;
    if (input.down.down) state.controllable.y += speed * delta_time;
    if (input.down.up) state.controllable.y -= speed * delta_time;
}

pub fn clampControllableToScreen(state: *State, screen_w: f32, screen_h: f32) void {
    const cur_x = state.controllable.x;
    const cur_y = state.controllable.y;
    const size = state.controllable.size;
    state.controllable.x = std.math.clamp(cur_x, size, screen_w - size);
    state.controllable.y = std.math.clamp(cur_y, size, screen_h - size);
}

pub fn updateEntities(state: *State, delta_time: f32) void {
    for (state.entities.items) |e|
        e.y += e.speed * delta_time;
    for (state.projectiles.items) |p|
        p.y -= p.speed * delta_time;
}

pub fn addProjectile(state: *State, input: Input) !void {
    if (state.controllable.weapon) |weapon| {
        const current_time = platform.getTime();
        const last_shot_time = weapon.last_shot_time;
        const reload_time = weapon.reload_time;
        std.debug.print("time since last shot: {d}\n", .{ current_time - last_shot_time });
        if (input.pressed.space and reload_time < current_time - last_shot_time) {
            const controllable = state.controllable;
            const projectile_params: EntityParams = .{
                .x = controllable.x,
                .y = controllable.y - controllable.size / 2.0,
                .size = weapon.size,
                .speed = weapon.speed,
                .color = weapon.color,
            };
            try state.addProjectile(projectile_params);
            weapon.last_shot_time = current_time;
        }
    }
}

pub fn generateRandomEntity(
    state: *State,
    random: *Random,
    screen_w: f32,
) !void {
    const params = state.entity_random_params;
    if (random.intRangeAtMost(0, 99) >= params.generation_chance) {
        const size = random.genFloatRange(params.min_size, params.max_size);
        const entity_params: EntityParams = .{
            .x = random.genFloatRange(size / 2.0, screen_w - size / 2.0),
            .y = -size,
            .size = size,
            .speed = random.genFloatRange(params.min_speed, params.max_speed),
            .color = random.randomColor(params.colors),
        };
        try state.addEntity(entity_params);
    }
}

pub fn removeOffscreenEntities(state: *State, screen_h: f32) void {
    const entities = &state.entities;
    const projectiles = &state.projectiles;
    var i: usize = entities.items.len;
    while (i > 0) {
        i -= 1;
        if (entities.items[i].y > screen_h + entities.items[i].size)
            _ = entities.swapRemove(i);
    }
    i = projectiles.items.len;
    while (i > 0) {
        i -= 1;
        if (projectiles.items[i].y < 0.0 - projectiles.items[i].size / 2.0)
            _ = projectiles.swapRemove(i);
    }
}

pub fn removeCollidedEntities(state: *State) void {
    const entities = &state.entities;
    const projectiles = &state.projectiles;
    var i: usize = entities.items.len;
    while (i > 0) {
        i -= 1;
        if (entities.items[i].collided)
            _ = entities.swapRemove(i);
    }
    i = projectiles.items.len;
    while (i > 0) {
        i -= 1;
        if (projectiles.items[i].collided)
            _ = projectiles.swapRemove(i);
    }
}

pub fn checkCollisions(state: *State) void {
    const controllable = state.controllable;
    const entities = state.entities;
    const projectiles = state.projectiles;
    for (entities.items) |e|
        if (controllable.is_collided(e)) {
            state.running = false;
            break;
        };
    for (entities.items) |e|
        for (projectiles.items) |p|
            if (p.is_collided(e)) {
                p.collided = true;
                e.collided = true;
            };
}

