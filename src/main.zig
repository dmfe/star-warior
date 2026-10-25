const std = @import("std");
const rl = @import("raylib");

pub fn main() void {
    const width = 800;
    const height = 600;

    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(width, height, "Star Warior");
    defer rl.closeWindow();

    const radius: f32 = 16.0;
    const movement_speed: f32 = 400.0;
    var x: f32 = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2.0;
    var y: f32 = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2.0;

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.dark_purple);

        const delta_time: f32 = rl.getFrameTime();
        const screen_widht: f32 = @floatFromInt(rl.getScreenWidth());
        const screen_height: f32 = @floatFromInt(rl.getScreenHeight());

        if (rl.isKeyDown(.right)) x += movement_speed * delta_time;
        if (rl.isKeyDown(.left)) x -= movement_speed * delta_time;
        if (rl.isKeyDown(.down)) y += movement_speed * delta_time;
        if (rl.isKeyDown(.up)) y -= movement_speed * delta_time;

        x = std.math.clamp(x, radius, screen_widht - radius);
        y = std.math.clamp(y, radius, screen_height - radius);

        rl.drawCircleV(.{ .x = x, .y = y }, radius, .yellow);
    }
}

