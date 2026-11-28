const core = @import("core");
const resources_module = @import("resources");

const Player = core.Player;
const PlayerVisualState = core.PlayerVisualState;

const ResourceManager = resources_module.ResourceManager;
const TextureHandle = resources_module.TextureHandle;

const SpriteSheet = @import("sprite_sheet.zig");
const SpriteAnimation = @import("sprite_animation.zig");

const Self = @This();
texture: TextureHandle,
animation: SpriteAnimation,
sheet: SpriteSheet,

pub fn init(
    resources: *const ResourceManager,
) !Self {
    return .{
        .texture = try resources.requireTexture(
            "texture/player",
        ),
        .animation = .{},
        .sheet = .{
            .columns = 2,
            .rows = 5,
        },
    };
}

pub fn update(
    self: *Self,
    delta_time: f32,
) void {
    self.animation.update(
        delta_time,
        self.sheet.columns,
    );
}

pub fn draw(
    self: *const Self,
    resources: *const ResourceManager,
    player: *const Player,
) void {
    const texture = resources.getTextureConst(
        self.texture,
    ) orelse return;

    const source = self.sheet.frameRegion(
        texture.width(),
        texture.height(),
        playerRow(player.visual_state),
        self.animation.frame,
    );

    const body = player.body;
    texture.drawRegion(
        source,
        body.position,
        .{
            .x = source.width,
            .y = source.height,
        },
        .white,
    );
}

fn playerRow(state: PlayerVisualState) u32 {
    return switch (state) {
        .straight => 0,
        .left => 1,
        .left_hard => 2,
        .right => 3,
        .right_hard => 4,
    };
}

