const std = @import("std");
const Region = @import("platform").Texture.Region;

const Self = @This();
rows: u32,
columns: u32,

pub fn frameRegion(
    self: *const Self,
    texture_width: u32,
    texture_height: u32,
    row: u32,
    column: u32,
) Region {
    std.debug.assert(row < self.rows);
    std.debug.assert(column < self.columns);

    const frame_width: f32 =
        @as(f32, @floatFromInt(texture_width)) /
        @as(f32, @floatFromInt(self.columns));
    const frame_height: f32 =
        @as(f32, @floatFromInt(texture_height)) /
        @as(f32, @floatFromInt(self.rows));

    return .{
        .x = @as(f32, @floatFromInt(column)) * frame_width,
        .y = @as(f32, @floatFromInt(row)) * frame_height,
        .width = frame_width,
        .height = frame_height,
    };
}
