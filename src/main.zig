const std = @import("std");
const rl = @import("raylib");

pub fn main() void {
    const width = 800;
    const height = 600;

    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(width, height, "Star Warior");
    defer rl.closeWindow();

    var x = @divTrunc(rl.getScreenWidth(), 2);
    var y = @divTrunc(rl.getScreenHeight(), 2);

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.dark_purple);

        if (rl.isKeyDown(.right)) x += 3;
        if (rl.isKeyDown(.left)) x -= 3;
        if (rl.isKeyDown(.down)) y += 3;
        if (rl.isKeyDown(.up)) y -= 3;

        rl.drawCircle(x, y, 16, .yellow);
    }
}

