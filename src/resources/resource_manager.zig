const std = @import("std");
const platform = @import("platform");

const ResourceStorage = @import("resource_storage.zig").ResourceStorage;
const ShaderHandle = @import("handles.zig").ShaderHandle;

const Shader = platform.Shader;

fn destroyShader(shader: *Shader) void {
    shader.deinit();
}

const ShaderStorage = ResourceStorage(
    Shader,
    ShaderHandle,
    destroyShader,
);

const Self = @This();
allocator: std.mem.Allocator,
shaders: ShaderStorage,

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .shaders = ShaderStorage.init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.shaders.deinit();
    self.* = undefined;
}

pub fn loadShader(
    self: *Self,
    id: []const u8,
    path: [:0]const u8,
) !ShaderHandle {
    if (self.findShader(id)) |_|
        return error.DuplicateResourceId;

    var shader = try Shader.init(
        path,
        self.allocator,
    );
    errdefer shader.deinit();

    return try self.shaders.insert(id, shader);
}

pub fn findShader(
    self: *const Self,
    id: []const u8,
) ?ShaderHandle {
    return self.shaders.find(id);
}

pub fn requireShader(
    self: *const Self,
    id: []const u8,
) !ShaderHandle {
    return self.shaders.require(id);
}

pub fn getShader(
    self: *Self,
    handle: ShaderHandle,
) ?*Shader {
    return self.shaders.get(handle);
}

pub fn getShaderConst(
    self: *const Self,
    handle: ShaderHandle,
) ?*const Shader {
    return self.shaders.getConst(handle);
}

