const Input = @import("core").Input;
const Context = @import("../layer_context.zig").Context;
const Command = @import("../layer_command.zig").Command;

const Self = @This();

pub fn handleInput(
    self: *Self,
    input: Input,
    context: *Context
) Command {
    _ = self;
    _ = context;

    if (input.pressed.escape) return .{ .push = .pause_menu };
    if (input.pressed.inventory) return .{ .push = .inventory };
    return .none;
}

pub fn draw(
    self: *const Self,
    context: *const Context,
) void {
    _ = self;
    _ = context;
}

