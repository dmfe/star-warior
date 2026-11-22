const std = @import("std");
const builtin = @import("builtin");
const rl = @import("raylib");
const common = @import("common");

const Vec2 = common.Vec2;

pub const Self = @This();
native: rl.Shader,
time_location: i32,
resolution_location: i32,
direction_location: i32,

pub fn init(
    path: [:0]const u8,
    allocator: std.mem.Allocator
) !Self {
    const shader_resources_path = if (builtin.target.os.tag == .emscripten)
        "assets/shaders/web"
    else
        "assets/shaders/desktop";

    const shader_path = if (builtin.target.os.tag == .emscripten)
        try std.fs.path.joinZ(
            allocator,
            &.{ "/", shader_resources_path, path },
        )
    else
        try std.fs.path.joinZ(
            allocator,
            &.{ rl.getApplicationDirectory(), shader_resources_path, path },
        );
    defer allocator.free(shader_path);

    const native = try rl.loadShader(null, shader_path);
    errdefer rl.unloadShader(native);

    return .{
        .native = native,
        .time_location = rl.getShaderLocation(
            native,
            "iTime",
        ),
        .resolution_location = rl.getShaderLocation(
            native,
            "iResolution",
        ),
        .direction_location = rl.getShaderLocation(
            native,
            "direction_modifier",
        ),
    };
}

pub fn deinit(self: *Self) void {
    rl.unloadShader(self.native);
    self.* = undefined;
}

pub fn update(
    self: *Self,
    resolution: Vec2,
    time: f32,
    direction_modifier: f32,
) void {
    const res_arr = [2]f32{ resolution.x, resolution.y };

    rl.setShaderValue(
        self.native,
        self.time_location,
        &time,
        .float,
    );
    rl.setShaderValue(
        self.native,
        self.resolution_location,
        &res_arr,
        .vec2,
    );
    rl.setShaderValue(
        self.native,
        self.direction_location,
        &direction_modifier,
        .float,
    );
}

pub fn draw(
    self: *const Self,
    resolution: Vec2,
) void {
    rl.beginShaderMode(self.native);
    defer rl.endShaderMode();

    rl.drawRectangle(
        0,
        0,
        @intFromFloat(resolution.x),
        @intFromFloat(resolution.y),
        .white,
    );
}

