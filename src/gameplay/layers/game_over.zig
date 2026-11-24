const core = @import("core");
const rendering = @import("rendering");

const drawCenteredText = rendering.drawCenteredText;

const Input = core.Input;

const Context = @import("../layer_context.zig").Context;
const Command = @import("../layer_command.zig").Command;

const Self = @This();

pub fn handleInput(
    self: *Self,
    input: Input,
    context: *Context,
) Command {
    _ = self;
    _ = context;

    if (input.pressed.space)
        return .restart_game;
    if (input.pressed.escape)
        return .return_to_menu;

    return .none;
}

pub fn draw(
    self: *const Self,
    context: *const Context,
) !void {
    _ = self;
    _ = context;

    try drawCenteredText("GAME OVER", 50.0, 0.8, .red);
    try drawCenteredText("Space: restart", 24.0, 1.2, .white);
    try drawCenteredText("Escape: main menu", 24.0, 1.4, .white);
}

