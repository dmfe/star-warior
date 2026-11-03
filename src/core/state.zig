const std = @import("std");
const Entity = @import("entity.zig");

const Self = @This();
controllable: Entity,
entities: std.ArrayList(Entity),

pub fn init(controllable: Entity) Self {
    return .{
        .controllable = controllable,
        .entities = .empty,
    };
}

pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    self.entities.deinit(allocator);
}

