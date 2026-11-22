const std = @import("std");
const Layer = @import("layer.zig").Layer;

pub const Error = error{
    LayerStackFull,
    LayerStackEmpty,
    CannotRemoveLastLayer,
};

pub const LayerStack = struct {
    const capacity = 8;

    layers: [capacity]Layer = undefined,
    len: usize = 0,

    pub fn init(init_layer: Layer) LayerStack {
        var result: LayerStack = .{};
        result.layers[0] = init_layer;
        result.len = 1;
        return result;
    }

    pub fn count(self: *const LayerStack) usize {
        return self.len;
    }

    pub fn items(self: *LayerStack) []Layer {
        return self.layers[0..self.len];
    }

    pub fn constItems(self: *const LayerStack) []const Layer {
        return self.layers[0..self.len];
    }

    pub fn top(self: *LayerStack) Error!*Layer {
        if (self.len < 1) return error.LayerStackEmpty;
        return &self.layers[self.len - 1];
    }

    pub fn push(self: *LayerStack, layer: Layer) Error!void {
        if (self.len == capacity) return error.LayerStackFull;
        self.layers[self.len] = layer;
        self.len += 1;
    }

    pub fn pop(self: *LayerStack) Error!void {
        if (self.len <= 1) return error.CannotRemoveLastLayer;
        self.len -= 1;
    }

    pub fn replaceTop(self: *LayerStack, layer: Layer) !void {
        if (self.len < 1) return error.LayerStackEmpty;
        self.layers[self.len - 1] = layer;
    }

    pub fn reset(self: *LayerStack, layer: Layer) void {
        self.layers[0] = layer;
        self.len = 1;
    }

    pub fn blocksSimulationUpdate(self: *const LayerStack) bool {
        for (self.constItems()) |*layer|
            if (layer.policy().blocks_update_below)
                return true;

        return false;
    }
};

