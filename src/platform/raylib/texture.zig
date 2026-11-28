const std = @import("std");
const rl = @import("raylib");
const common = @import("common");
const builtin = @import("builtin");

const Vec2 = common.Vec2;
const Color = common.Color;

pub const Region = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

const Self = @This();
native: rl.Texture2D,

pub fn init(
    path: [:0]const u8,
    allocator: std.mem.Allocator,
) !Self {
    const texture_resources_path = "assets/textures";
    const texture_path = if (builtin.target.os.tag == .emscripten)
        try std.fs.path.joinZ(
            allocator,
            &.{ "/", texture_resources_path, path },
        )
    else
        try std.fs.path.joinZ(
            allocator,
            &.{ rl.getApplicationDirectory(), texture_resources_path, path },
        );
    defer allocator.free(texture_path);

    const native = try rl.loadTexture(texture_path);
    errdefer rl.unloadTexture(native);

    return .{
        .native = native,
    };
}

pub fn deinit(self: *Self) void {
    rl.unloadTexture(self.native);
    self.* = undefined;
}

pub fn width(self: *const Self) u32 {
    return @intCast(self.native.width);
}

pub fn height(self: *const Self) u32 {
    return @intCast(self.native.height);
}

pub fn drawRegion(
    self: *const Self,
    source: Region,
    position: Vec2,
    size: Vec2,
    tint: Color,
) void {
    const destination: rl.Rectangle = .{
        .x = position.x,
        .y = position.y,
        .width = size.x,
        .height = size.y,
    };

    rl.drawTexturePro(
        self.native,
        .{
            .x = source.x,
            .y = source.y,
            .width = source.width,
            .height = source.height,
        },
        destination,
        .{
            .x = size.x / 2.0,
            .y = size.y / 2.0,
        },
        0.0,
        .{
            .r = tint.r,
            .g = tint.g,
            .b = tint.b,
            .a = tint.a,
        },
    );
}

