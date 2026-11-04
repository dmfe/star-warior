const std = @import("std");
const Entity = @import("entity.zig");

const Self = @This();
controllable: Entity,
entities: std.ArrayList(Entity),
running: bool,

pub fn init(controllable: Entity) Self {
    return .{
        .controllable = controllable,
        .entities = .empty,
        .running = true,
    };
}

pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    self.entities.deinit(allocator);
}

pub fn reset(self: *Self, start_x: f32, start_y: f32) void {
    self.controllable.x = start_x;
    self.controllable.y = start_y;
    self.entities.clearRetainingCapacity();
    self.running = true;
}

