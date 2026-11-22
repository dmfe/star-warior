const core = @import("core");
const render = core.render;
const Input = core.Input;
const Context = @import("../layer_context.zig").Context;
const Command = @import("../layer_command.zig").Command;
const Settings = @import("settings").Settings;

const Self = @This();
draft: Settings,
selected_item: usize = 0,

pub fn init(settings: Settings) Self {
    return .{
        .draft = settings,
    };
}

pub fn handleInput(
    self: *Self,
    input: Input,
    context: *Context
) Command {
    if (input.pressed.escape)
        return .pop;
    if (input.pressed.left)
        self.decreaseSelectedValue();
    if (input.pressed.right)
        self.increaseSelectedValue();
    if (input.pressed.space) {
        context.settings.* = self.draft;
        return .pop;
    }

    return .none;
}

fn decreaseSelectedValue(self: *Self) void {
    self.draft.master_volume = @max(0.0, self.draft.master_volume - 0.1);
}

fn increaseSelectedValue(self: *Self) void {
    self.draft.master_volume = @min(1.0, self.draft.master_volume + 0.1);
}

pub fn draw(
    self: *const Self,
    context: *const Context
) !void {
    _ = self;
    _ = context;

    try render.drawCenteredText("SETTINGS", 50.0, 0.8, .white);
}

