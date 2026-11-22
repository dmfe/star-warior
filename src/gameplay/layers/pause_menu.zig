const core = @import("core");
const common = @import("common");
const render = core.render;
const Input = core.Input;
const Color = common.Color;
const Context = @import("../layer_context.zig").Context;
const Command = @import("../layer_command.zig").Command;

const Self = @This();
selected_item: usize = 0,

const item_count = 3;

pub fn handleInput(
    self: *Self,
    input: Input,
    context: *Context,
) Command {
    _ = context;

    if (input.pressed.escape) return .pop;

    if (input.pressed.up) {
        self.selected_item = if (self.selected_item == 0)
            item_count - 1
        else
            self.selected_item - 1;
    }

    if (input.pressed.down)
        self.selected_item = (self.selected_item + 1) % item_count;

    if (input.pressed.space)
        return switch (self.selected_item) {
            0 => .pop,
            1 => .{ .push = .settings },
            2 => .return_to_menu,
            else => unreachable,
        };

    return .none;
}

pub fn draw(
    self: *const Self,
    context: *const Context,
) !void {
    _ = context;

    const resume_color: Color = if (self.selected_item == 0) .yellow else .white;
    const settings_color: Color = if (self.selected_item == 1) .yellow else .white;
    const menu_color: Color = if (self.selected_item == 2) .yellow else .white;

    try render.drawCenteredText("PAUSED", 50.0, 0.8, .white);
    try render.drawCenteredText("Resume", 24.0, 1.2, resume_color);
    try render.drawCenteredText("Settings", 24.0, 1.4, settings_color);
    try render.drawCenteredText("Main menu", 24.0, 1.6, menu_color);
}

