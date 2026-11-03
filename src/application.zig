const std = @import("std");
const platform = @import("platform");
const Random = @import("common").Random;
const Scene = @import("core").Scene;

pub const Config = struct {
    title: [:0]const u8,
    width: i32,
    height: i32,
    resizable: bool,
};

const Self = @This();
scene: Scene,

pub fn init(config: Config) Self {
    const allocator = std.heap.c_allocator;
    const random = Random.init();

    platform.initWindow(config.width, config.height, config.title, config.resizable);
    errdefer platform.closeWindow();

    const scene = Scene.init(allocator, random);
    errdefer scene.deinit();

    return .{
        .scene = scene,
    };
}

pub fn deinit(self: *Self) void {
    self.scene.deinit();
    platform.closeWindow();
}

pub fn run(self: *Self) !void {
    while (!platform.shouldClose()) {
        platform.beginFrame();
        defer platform.endFrame();

        try self.scene.update();
        try self.scene.draw();
    }

}

