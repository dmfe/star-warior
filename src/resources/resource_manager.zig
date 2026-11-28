const std = @import("std");
const platform = @import("platform");
const handles = @import("handles.zig");

const ResourceStorage = @import("resource_storage.zig").ResourceStorage;
const ShaderHandle = handles.ShaderHandle;
const TextureHandle = handles.TextureHandle;

const Shader = platform.Shader;

fn destroyShader(shader: *Shader) void {
    shader.deinit();
}

const ShaderStorage = ResourceStorage(
    Shader,
    ShaderHandle,
    destroyShader,
);

const Texture = platform.Texture;

fn destroyTexture(texture: *Texture) void {
    texture.deinit();
}

const TextureStorage = ResourceStorage(
    Texture,
    TextureHandle,
    destroyTexture,
);

const Self = @This();
allocator: std.mem.Allocator,
shaders: ShaderStorage,
textures: TextureStorage,

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .shaders = ShaderStorage.init(allocator),
        .textures = TextureStorage.init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.textures.deinit();
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

pub fn loadTexture(
    self: *Self,
    id: []const u8,
    path: [:0]const u8,
) !TextureHandle {
    if (self.findTexture(id)) |_|
        return error.DuplicateResourceId;

    var texture = try Texture.init(
        path,
        self.allocator,
    );
    errdefer texture.deinit();

    return try self.textures.insert(id, texture);
}

pub fn findTexture(
    self: *const Self,
    id: []const u8,
) ?TextureHandle {
    return self.textures.find(id);
}

pub fn requireTexture(
    self: *const Self,
    id: []const u8,
) !TextureHandle {
    return self.textures.require(id);
}

pub fn getTexture(
    self: *Self,
    handle: TextureHandle,
) ?*Texture {
    return self.textures.get(handle);
}

pub fn getTextureConst(
    self: *const Self,
    handle: TextureHandle,
) ?*const Texture {
    return self.textures.getConst(handle);
}

