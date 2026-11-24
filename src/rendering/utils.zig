const platform = @import("platform");
const Color = @import("common").Color;

pub fn drawCenteredText(
    text: [:0]const u8,
    font_size: f32,
    y_shift: f32,
    color: Color
) !void {
    const screen_width = platform.screenWidth();
    const screen_height = platform.screenHeight();
    const text_size = try platform.measureText(text, font_size);
    const x = @as(i32, @intFromFloat(screen_width / 2.0 - text_size.x / 2.0));
    const y = @as(i32, @intFromFloat(screen_height / 2.0 * y_shift));
    platform.drawText(
        text,
        x,
        y,
        @as(i32, @intFromFloat(font_size)),
        color, 
    );
}

