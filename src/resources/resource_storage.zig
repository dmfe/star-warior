const std = @import("std");

pub fn ResourceStorage(
    comptime Resource: type,
    comptime Handle: type,
    comptime destroyResource: fn (*Resource) void,
) type {
    return struct {
        const Entry = struct {
            id: []u8,
            resource: Resource,
        };

        const Self = @This();
        allocator: std.mem.Allocator,
        handles: std.StringHashMapUnmanaged(Handle) = .empty,
        entries: std.ArrayList(Entry) = .empty,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.handles.deinit(self.allocator);

            var index = self.entries.items.len;
            while (index > 0) {
                index -= 1;
                var entry = &self.entries.items[index];
                destroyResource(&entry.resource);
                self.allocator.free(entry.id);
            }
            self.entries.deinit(self.allocator);
            self.* = undefined;
        }

        pub fn insert(
            self: *Self,
            id: []const u8,
            resource: Resource,
        ) !Handle {
            if (id.len == 0)
                return error.EmptyResourceId;
            if (self.handles.contains(id))
                return error.DuplicateResourceId;
            if (self.entries.items.len > std.math.maxInt(u32))
                return error.TooManyResources;

            try self.entries.ensureUnusedCapacity(self.allocator, 1);
            try self.handles.ensureUnusedCapacity(self.allocator, 1);

            const owned_id = try self.allocator.dupe(u8, id);
            errdefer self.allocator.free(owned_id);

            const handle: Handle = @enumFromInt(
                @as(u32, @intCast(self.entries.items.len)),
            );

            self.entries.appendAssumeCapacity(.{
                .id = owned_id,
                .resource = resource,
            });
            self.handles.putAssumeCapacityNoClobber(
                owned_id,
                handle,
            );

            return handle;
        }

        pub fn find(
            self: *const Self,
            id: []const u8,
        ) ?Handle {
            return self.handles.get(id);
        }

        pub fn require(
            self: *const Self,
            id: []const u8,
        ) !Handle {
            return self.find(id) orelse
                error.ResourceNotFound;
        }

        pub fn get(
            self: *Self,
            handle: Handle,
        ) ?*Resource {
            const index: usize = @intFromEnum(handle);

            if (index >= self.entries.items.len)
                return null;

            return &self.entries.items[index].resource;
        }

        pub fn getConst(
            self: *const Self,
            handle: Handle,
        ) ?*const Resource {
            const index: usize = @intFromEnum(handle);

            if (index >= self.entries.items.len)
                return null;

            return &self.entries.items[index].resource;
        }

        pub fn count(self: *const Self) usize {
            return self.entries.items.len;
        }
    };
}

