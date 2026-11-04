const std = @import("std");
const platform = @import("platform");
const logic = @import("logic.zig");
const render = @import("render.zig");
const input = @import("input.zig");
const State = @import("state.zig");
const Entity = @import("entity.zig");
const common = @import("common");
const Color = common.Color;
const Random = common.Random;

const Self = @This();
state: State,
allocator: std.mem.Allocator,
random: Random,
entitiesParams: logic.EntitiesParams,

pub fn init(allocator: std.mem.Allocator, random: Random) Self {
    const controllable: Entity = .{
        .x = platform.screenWidth() / 2.0,
        .y = platform.screenHeight() / 2.0,
        .size = 32.0,
        .speed = 400.0,
        .color = Color.yellow,
    };
    var state = State.init(controllable);
    errdefer state.deinit(allocator);

    const entities_colors = [_]Color{
        .red,
        .blue,
        .green,
        .orange,
        .purple,
        .gold,
    };
    const entitiesParams: logic.EntitiesParams = .{
        .generation_chance = 85,
        .min_size = 16.0,
        .max_size = 64.0,
        .min_speed = 50.0,
        .max_speed = 150.0,
        .colors = entities_colors[0..],
    };
    return .{
        .state = state,
        .allocator = allocator,
        .random = random,
        .entitiesParams = entitiesParams,
    };
}

pub fn deinit(self: *Self) void {
    self.state.deinit(self.allocator);
}

pub fn update(self: *Self) !void {
    const delta_time: f32 = platform.deltaTime();
    const screen_width: f32 = platform.screenWidth();
    const screen_height: f32 = platform.screenHeight();

    const inp = input.poll();
    if (self.state.running) {
        const controllable = &self.state.controllable;
        const entities = &self.state.entities;
        logic.updateControllable(controllable, inp, delta_time);
        logic.clampEntityToScreen(controllable, screen_width, screen_height);
        try logic.generateRandomEntities(&self.random, self.allocator, entities, self.entitiesParams, screen_width);
        logic.updateEntities(entities.items, delta_time);
        logic.removeOffscreenEntities(entities, screen_height);
        if (logic.collidedWithEntities(controllable, entities.items))
            self.state.running = false;
    } else if (inp.space) {
        self.state.reset(screen_width / 2.0, screen_height / 2.0);
    }
}

pub fn draw(self: *Self) !void {
    const controllable = &self.state.controllable;
    const entities = &self.state.entities;
    render.drawControllable(controllable);
    render.drawEntities(entities.items);
    try render.drawFPS();
    try render.drawEntitiesCount(entities.items);
    if (!self.state.running) {
        try render.drawSimulationIsOverText("GAME OVER");
    }
}

