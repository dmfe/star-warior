const std = @import("std");
const core = @import("core");
const render = core.render;
const Input = core.Input;
const Context = @import("../layer_context.zig").Context;
const Command = @import("../layer_command.zig").Command;

const Self = @This();
selected_slot: usize = 0,

pub fn handleInput(
    self: *Self,
    input: Input,
    context: *Context,
) Command {
    const inventory = &context.simulation.player.inventory;

    if (input.pressed.escape or input.pressed.inventory)
        return .pop;
    if (input.pressed.left and self.selected_slot > 0)
        self.selected_slot -= 1;
    if (input.pressed.right and self.selected_slot + 1 < inventory.slots.len)
        self.selected_slot += 1;
    if (input.pressed.space)
        context.simulation.useInventoryItem(self.selected_slot);

    return .none;
}

pub fn draw(
    self: *const Self,
    context: *const Context,
) !void {
    const inventory = &context.simulation.player.inventory;

    try render.drawCenteredText("INVENTORY", 40.0, 0.8, .white);

    var buffer: [64]u8 = undefined;
    const text = if (inventory.slots[self.selected_slot]) |item|
        try std.fmt.bufPrintSentinel(
            &buffer,
            "Slot {d}: {s} x{d}",
            .{
                self.selected_slot + 1,
                @tagName(item.kind),
                item.count,
            },
            0,
        )
    else
        try std.fmt.bufPrintSentinel(
            &buffer,
            "Slot {d}: empty",
            .{self.selected_slot + 1},
            0,
        );

    try render.drawCenteredText(text, 24.0, 1.1, .yellow);
    try render.drawCenteredText(
        "Left/Right: select  Space: use  I/Escape: close",
        18.0,
        1.3,
        .white,
    );
}
