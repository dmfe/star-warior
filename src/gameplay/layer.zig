const Input = @import("core").Input;
const Context = @import("layer_context.zig").Context;
const Command = @import("layer_command.zig").Command;

const PlayingLayer = @import("layers/playing.zig");
const PauseMenuLayer = @import("layers/pause_menu.zig");
const InventoryLayer = @import("layers/inventory.zig");
const SettingsLayer = @import("layers/settings.zig");
const GameOverLayer = @import("layers/game_over.zig");

pub const Policy = struct {
    blocks_update_below: bool = false,
    blocks_input_below: bool = true,
    blocks_render_below: bool = false,
};

pub const Layer = union(enum) {
    playing: PlayingLayer,
    pause_menu: PauseMenuLayer,
    inventory: InventoryLayer,
    settings: SettingsLayer,
    game_over: GameOverLayer,

    pub fn policy(self: *const Layer) Policy {
        return switch (self.*) {
            .playing => .{},
            .pause_menu => .{
                .blocks_update_below = true,
            },
            .inventory => .{
                .blocks_update_below = true,
            },
            .settings => .{
                .blocks_update_below = true,
                .blocks_render_below = true,
            },
            .game_over => .{
                .blocks_update_below = true,
            },
        };
    }

    pub fn handleInput(
        self: *Layer,
        context: *Context,
        input: Input,
    ) Command {
        return switch (self.*) {
            .playing => |*state| state.handleInput(input, context),
            .pause_menu => |*state| state.handleInput(input, context),
            .inventory => |*state| state.handleInput(input, context),
            .settings => |*state| state.handleInput(input, context),
            .game_over => |*state| state.handleInput(input, context),
        };
    }

    pub fn draw(
        self: *const Layer,
        context: *const Context,
    ) !void {
        switch (self.*) {
            .playing => |*state| state.draw(context),
            .pause_menu => |*state| try state.draw(context),
            .inventory => |*state| try state.draw(context),
            .settings => |*state| try state.draw(context),
            .game_over => |*state| try state.draw(context),
        }
    }
};

