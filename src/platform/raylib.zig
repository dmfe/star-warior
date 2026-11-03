const rl = @import("raylib");
const common = @import("common");
const Color = common.Color;
const Direction = common.Direction;

// Window
pub fn initWindow(width: i32, height: i32, title: [:0]const u8, resizable: bool) void {
    rl.setConfigFlags(.{ .window_resizable = resizable });
    rl.initWindow(width, height, title);
    rl.setTargetFPS(60);
}

pub fn closeWindow() void {
    rl.closeWindow();
}

pub fn shouldClose() bool {
    return rl.windowShouldClose();
}


// Time / size / frame
pub fn deltaTime() f32 {
    return rl.getFrameTime();
}

pub fn getFPS() i32 {
    return rl.getFPS();
}

pub fn screenWidth() f32 {
    return @floatFromInt(rl.getScreenWidth());
}

pub fn screenHeight() f32 {
    return @floatFromInt(rl.getScreenHeight());
}

// Input
pub fn isKeyDown(direction: Direction) bool {
    return rl.isKeyDown(switch (direction) {
        .left => .left,
        .right => .right,
        .up => .up,
        .down => .down,
    });
}

// Frame
pub fn beginFrame() void {
    rl.beginDrawing();
    rl.clearBackground(.dark_purple);
}

pub fn endFrame() void {
    rl.endDrawing();
}

// Primitive drawing
pub fn drawRect(x: f32, y: f32, w: f32, h: f32, color: Color) void {
    rl.drawRectangleRec(.{
        .x = x,
        .y = y,
        .width = w,
        .height = h,
    },
    .{
        .r = color.r,
        .g = color.g,
        .b = color.b,
        .a = color.a,
    });
}

pub fn drawCircle(x: f32, y: f32, radius: f32, color: Color) void {
    rl.drawCircleV(.{ .x = x, .y = y }, radius, .{
        .r = color.r,
        .g = color.g,
        .b = color.b,
        .a = color.a,
    });
}

pub fn drawText(text: [:0]const u8, x: i32, y: i32, size: i32, color: Color) void {
    rl.drawText(text, x, y, size, .{
        .r = color.r,
        .g = color.g,
        .b = color.b,
        .a = color.a,
    });
}

