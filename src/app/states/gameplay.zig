const std = @import("std");
const common = @import("common");
const core = @import("core");
const settings_module = @import("settings");
const gameplay = @import("gameplay");

const Random = common.Random;
const Input = core.Input;
const Simulation = core.Simulation;
const Settings = settings_module.Settings;
const Layer = gameplay.Layer;
const LayerStack = gameplay.LayerStack;
const LayerContext = gameplay.LayerContext;
const LayerCommand = gameplay.LayerCommand;
const SettingsLayer = gameplay.SettingsLayer;
const AppCommand = @import("../command.zig").Command;

const Self = @This();
simulation: Simulation,
layers: LayerStack,

pub fn init(
    allocator: std.mem.Allocator,
    random: Random,
) !Self {
    var simulation =try Simulation.init(
        allocator,
        random,
    );
    errdefer simulation.deinit();

    return .{
        .simulation = simulation,
        .layers = LayerStack.init(.{
            .playing = .{},
        }),
    };
}

pub fn deinit(self: *Self) void {
    self.simulation.deinit();
}

pub fn update(
    self: *Self,
    input: Input,
    delta_time: f32,
    settings: *Settings,
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
        const event = try self.simulation.update(
            input,
            delta_time,
        );

        switch (event) {
            .none => {},
            .player_died => {
                try self.layers.push(.{
                    .game_over = .{},
                });
            },
        }
    }

    return .none;
}

pub fn draw(
    self: *const Self,
    settings: *Settings,
) !void {
    try self.simulation.draw();

    const context: LayerContext = .{
        .simulation = @constCast(&self.simulation),
        .settings = settings,
    };

    const layers = self.layers.constItems();
    const start = firstVisibleLayer(layers);

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
            self.simulation.reset();
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

