const core = @import("core");
const render = core.render;
const Input = core.Input;
const AppCommand = @import("../command.zig").Command;

const Self = @This();

pub fn update(self: *Self, input: Input) AppCommand {
    _ = self;

    if (input.pressed.space)
        return .start_game;
    if (input.pressed.escape)
        return .exit;

    return .none;
}

pub fn draw(self: *const Self) !void {
    _ = self;

    try render.drawCenteredText(
        "STAR WARIOR",
        50.0,
        0.8,
        .white,
    );
    try render.drawCenteredText(
        "Space: start",
        25.0,
        1.2,
        .white,
    );
    try render.drawCenteredText(
        "Escape: exit",
        24.0,
        1.4,
        .white,
    );
}

