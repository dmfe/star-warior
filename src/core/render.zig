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
    platform.drawCircle(
        controllable.x,
        controllable.y,
        controllable.size / 2.0,
        controllable.color
    );
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

pub fn drawSimulationIsOverText(text: [:0]const u8) !void {
    const screen_width = platform.screenWidth();
    const screen_height = platform.screenHeight();
    const font_size: f32 = 50.0;
    const text_size = try platform.measureText(text, font_size);
    const x: i32 = @as(i32, @intFromFloat(screen_width / 2.0 - text_size.x / 2.0));
    const y: i32 = @as(i32, @intFromFloat(screen_height / 2.0));
    platform.drawText(
        text,
        x,
        y,
        @as(i32, @intFromFloat(font_size)),
        .red);
}

