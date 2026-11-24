const resources_module = @import("resources");
const ResourceManager = resources_module.ResourceManager;
const ShaderHandle = resources_module.ShaderHandle;
const Vec2 = @import("common").Vec2;

const Self = @This();
starfield_shader: ShaderHandle,

pub fn init(
    resources: *const ResourceManager,
) !Self {
    return .{
        .starfield_shader = try resources.requireShader(
            "shader/starfield"
        ),
    };
}

pub fn draw(
    self: *const Self,
    resources: *ResourceManager,
    resolution: Vec2,
    time: f32,
) void {
    if (resources.getShader(self.starfield_shader)) |shader| {
        shader.update(
            resolution,
            time,
            0.0,
        );
        shader.draw(resolution);
    }
}

