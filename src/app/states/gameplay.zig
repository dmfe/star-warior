const std = @import("std");
const common = @import("common");
const core = @import("core");
const settings_module = @import("settings");
const gameplay = @import("gameplay");
const rendering = @import("rendering");
const resources_module = @import("resources");
const storage = @import("../storage.zig");

const Random = common.Random;
const Vec2 = common.Vec2;

const Input = core.Input;
const Simulation = core.Simulation;
const SimulationContext = core.SimulationContext;
const Statistics = core.Statistics;

const Settings = settings_module.Settings;

const Layer = gameplay.Layer;
const LayerStack = gameplay.LayerStack;
const LayerContext = gameplay.LayerContext;
const LayerCommand = gameplay.LayerCommand;
const SettingsLayer = gameplay.SettingsLayer;
const AppCommand = @import("../command.zig").Command;

const ResourceManager = resources_module.ResourceManager;

const BackgroundRenderer = rendering.BackgroundRenderer;
const SimulationRenderer = rendering.SimulationRenderer;
const HudRenderer = rendering.HudRenderer;

const Self = @This();
simulation: Simulation,
layers: LayerStack,
statistics: Statistics,
background_renderer: BackgroundRenderer,
simulation_renderer: SimulationRenderer,
hud_renderer: HudRenderer,

pub fn init(
    allocator: std.mem.Allocator,
    random: Random,
    resources: *const ResourceManager,
) !Self {
    var simulation = try Simulation.init(
        allocator,
        random,
    );
    errdefer simulation.deinit();

    const max_score = storage.loadMaxScore();

    return .{
        .simulation = simulation,
        .layers = LayerStack.init(.{
            .playing = .{},
        }),
        .statistics = .{ .max_score = max_score },
        .background_renderer = try BackgroundRenderer.init(resources),
        .simulation_renderer = SimulationRenderer.init(resources),
        .hud_renderer = HudRenderer.init(resources),
    };
}

pub fn deinit(self: *Self) void {
    storage.saveMaxScore(self.statistics.max_score);
    self.simulation.deinit();
}

pub fn update(
    self: *Self,
    input: Input,
    settings: *Settings,
    delta_time: f32,
) !AppCommand {
    var context: LayerContext = .{
        .simulation = &self.simulation,
        .settings = settings,
    };

    const layer_command = self.dispatchInput(input, &context);
    const app_command = try self.applyLayerCommand(layer_command, settings);
    if (app_command != .none)
        return app_command;

    if (!self.layers.blocksSimulationUpdate()) {
        var simulation_context: SimulationContext = .{
            .statistics = &self.statistics,
        };

        const event = try self.simulation.update(
            input,
            delta_time,
            &simulation_context,
        );

        switch (event) {
            .none => {},
            .player_died => {
                try self.layers.push(.{
                    .game_over = .{},
                });
                storage.saveMaxScore(self.statistics.max_score);
            },
        }
    }

    return .none;
}

pub fn draw(
    self: *const Self,
    resources: *ResourceManager,
    settings: *Settings,
    resolution: Vec2,
    time: f32,
) !void {
    const simulation_view = self.simulation.view();
    self.background_renderer.draw(
        resources,
        resolution,
        time,
    );
    self.simulation_renderer.draw(
        resources,
        simulation_view,
    );
    try self.hud_renderer.draw(
        resources,
        &self.statistics,
        simulation_view,
    );

    const layers = self.layers.constItems();
    const start = firstVisibleLayer(layers);

    const context: LayerContext = .{
        .simulation = @constCast(&self.simulation),
        .settings = settings,
    };
    for (layers[start..]) |layer|
        try layer.draw(&context);
}

fn firstVisibleLayer(
    layers: []const Layer,
) usize {
    var start: usize = 0;
    for (layers, 0..) |layer, index| {
        if (layer.policy().blocks_render_below) {
            start = index;
        }
    }

    return start;
}

fn dispatchInput(
    self: *Self,
    input: Input,
    context: *LayerContext,
) LayerCommand {
    const layers = self.layers.items();

    var index = layers.len;
    while (index > 0) {
        index -= 1;

        const layer = &layers[index];
        const command = layer.handleInput(context, input);

        if (command != .none)
            return command;

        if (layer.policy().blocks_input_below)
            break;
    }

    return .none;
}

fn applyLayerCommand(
    self: *Self,
    command: LayerCommand,
    settings: *Settings,
) !AppCommand {
    switch (command) {
        .none => {},
        .pop => try self.layers.pop(),
        .push => |kind| {
            const layer: Layer = switch (kind) {
                .pause_menu => .{
                    .pause_menu = .{},
                },
                .inventory => .{
                    .inventory = .{},
                },
                .settings => .{
                    .settings = SettingsLayer.init(settings.*),
                },
            };

            try self.layers.push(layer);
        },
        .restart_game => {
            var simulation_context: SimulationContext = .{
                .statistics = &self.statistics,
            };

            self.simulation.reset(&simulation_context);
            self.layers.reset(.{
                .playing = .{},
            });
        },
        .return_to_menu => {
            return .return_to_menu;
        },
        .exit_application => {
            return .exit;
        },
    }

    return .none;
}

