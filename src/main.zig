const std = @import("std");
const rl = @import("raylib");

pub fn main() void {
    //std.debug.print("Starting Star Warior application\n", .{});

    const width = 800;
    const height = 600;

    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(width, height, "Star Warior");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.dark_purple);
        rl.drawText("Hello, Star Warior!", 190, 200, 20, .green);
    }

    //std.debug.print("Exiting Star Warior application\n", .{});
}

