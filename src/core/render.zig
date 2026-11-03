const std = @import("std");
const platform = @import("platform");
const Entity = @import("entity.zig");

pub fn drawEntities(entities: []const Entity) void {
    for (entities) |e|
        platform.drawRect(
            e.x - e.size / 2.0,
            e.y - e.size / 2.0, 
            e.size,
            e.size,
            e.color
        );
}

pub fn drawControllable(controllable: *const Entity) void {
    platform.drawCircle(controllable.x, controllable.y, controllable.size, controllable.color);
}

pub fn drawFPS() !void {
    var buf: [32]u8 = undefined;
    const fps_text = try std.fmt.bufPrintSentinel(
        &buf,
        "FPS: {d}",
        .{ platform.getFPS() },
        0,
    );
    platform.drawText(fps_text, 10, 10, 20, .dark_green);
}

pub fn drawEntitiesCount(entities: []const Entity) !void {
    var buf: [32]u8 = undefined;
    const entities_count_text = try std.fmt.bufPrintSentinel(
        &buf,
        "Entities count: {d}",
        .{ entities.len },
        0,
    );
    platform.drawText(entities_count_text, 10, 40, 20, .dark_green);
}

