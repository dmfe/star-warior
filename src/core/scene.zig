const std = @import("std");
const platform = @import("platform");
const logic = @import("logic.zig");
const render = @import("render.zig");
const input = @import("input.zig");
const State = @import("state.zig");
const EntityParams = @import("params/entity-params.zig");
const EntityRandomParams = @import("params/entity-random-params.zig");
const common = @import("common");
const Color = common.Color;
const Random = common.Random;

const Self = @This();
state: *State,
random: Random,

pub fn init(allocator: std.mem.Allocator, random: Random) !Self {
    const controllable_params: EntityParams = .{
        .x = platform.screenWidth() / 2.0,
        .y = platform.screenHeight() / 2.0,
        .size = 32.0,
        .speed = 400.0,
        .color = .yellow,
        .projectile_params = .{
            .size = 5.0,
            .speed = 800.0,
            .reload_time = 0.1,
            .color = .green,
        },
    };
    const entities_colors = [_]Color{
        .red,
        .blue,
        .green,
        .orange,
        .purple,
        .gold,
    };
    const entities_random_params: EntityRandomParams = .{
        .generation_chance = 85,
        .min_size = 16.0,
        .max_size = 64.0,
        .min_speed = 50.0,
        .max_speed = 150.0,
        .colors = entities_colors[0..],
    };
    const state_ptr = try State.init(allocator, controllable_params, entities_random_params);
    errdefer state_ptr.deinit();

    return .{
        .state = state_ptr,
        .random = random,
    };
}

pub fn deinit(self: *Self) void {
    self.state.deinit();
}

pub fn update(self: *Self) !void {
    const delta_time: f32 = platform.deltaTime();
    const screen_width: f32 = platform.screenWidth();
    const screen_height: f32 = platform.screenHeight();

    const inp = input.poll();
    const state = self.state;
    if (state.is_running()) {
        logic.updateControllable(state, inp, delta_time);
        logic.clampControllableToScreen(state, screen_width, screen_height);
        try logic.addProjectile(state, inp);
        try logic.generateRandomEntity(state, &self.random, screen_width);
        logic.updateEntities(state, delta_time);
        logic.removeOffscreenEntities(state, screen_height);
        logic.removeCollidedEntities(state);
        logic.checkCollisions(state);
    } else if (inp.pressed.space) {
        state.reset(screen_width / 2.0, screen_height / 2.0);
    }
}

pub fn draw(self: *Self) !void {
    const state = self.state;
    render.drawControllable(state);
    render.drawEntities(state);
    try render.drawFPS();
    try render.drawEntitiesCount(state);
    if (!self.state.is_running()) {
        try render.drawSimulationIsOverText("GAME OVER");
    }
}

