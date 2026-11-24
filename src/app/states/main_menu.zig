const core = @import("core");
const common = @import("common");
const resources_module = @import("resources");
const rendering = @import("rendering");

const drawCenteredText = rendering.drawCenteredText;
const BackgroundRenderer = rendering.BackgroundRenderer;

const Input = core.Input;

const Vec2 = common.Vec2;

const ResourceManager = resources_module.ResourceManager;

const AppCommand = @import("../command.zig").Command;

const Self = @This();
background_renderer: BackgroundRenderer,

pub fn init(
    resources: *const ResourceManager,
) !Self {
    return .{
        .background_renderer = try BackgroundRenderer.init(resources),
    };
}

pub fn update(
    self: *Self,
    input: Input,
) AppCommand {
    _ = self;

    if (input.pressed.space)
        return .start_game;
    if (input.pressed.escape)
        return .exit;

    return .none;
}

pub fn draw(
    self: *const Self,
    resources: *ResourceManager,
    resolution: Vec2,
    time: f32,
) !void {
    self.background_renderer.draw(
        resources,
        resolution,
        time,
    );

    try drawCenteredText(
        "STAR WARIOR",
        50.0,
        0.8,
        .white,
    );
    try drawCenteredText(
        "Space: start",
        25.0,
        1.2,
        .white,
    );
    try drawCenteredText(
        "Escape: exit",
        24.0,
        1.4,
        .white,
    );
}

