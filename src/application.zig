const std = @import("std");
const platform = @import("platform");
const Random = @import("common").Random;
const Simulation = @import("core").Simulation;

pub const Config = struct {
    title: [:0]const u8,
    width: i32,
    height: i32,
    resizable: bool,
};

const Self = @This();
simulation: Simulation,

pub fn init(config: Config) !Self {
    platform.initWindow(config.width, config.height, config.title, config.resizable);
    errdefer platform.closeWindow();

    const allocator = std.heap.c_allocator;
    const random = Random.init();

    const simulation = try Simulation.init(allocator, random);
    errdefer simulation.deinit();

    return .{
        .simulation = simulation,
    };
}

pub fn deinit(self: *Self) void {
    self.simulation.deinit();
    platform.closeWindow();
}

pub fn run(self: *Self) !void {
    while (!platform.shouldClose()) {
        platform.beginFrame();
        defer platform.endFrame();

        try self.simulation.update();
        try self.simulation.draw();
    }

}

