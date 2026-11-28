const Body = @import("body.zig");
const Weapon = @import("weapon.zig");
const Inventory = @import("inventory.zig");
const Input = @import("../input.zig");
const PlayerVisualState = @import("player_visual_state.zig").PlayerVisualState;

const Self = @This();
body: Body,
weapon: Weapon,
inventory: Inventory,
visual_state: PlayerVisualState = .straight,
turn_time: f32 = 0.0,

const hard_turn_delay: f32 = 0.5;

pub fn init(body: Body, weapon: Weapon) Self {
    return .{
        .body = body,
        .weapon = weapon,
        .inventory = .{},
    };
}

pub fn update(self: *Self, input: Input, delta_time: f32) void {
    const speed = self.body.speed;

    if (input.down.right and !input.down.left) {
        self.body.position.x += speed * delta_time;
        self.turn_time += delta_time;
        self.visual_state = if (self.turn_time >= hard_turn_delay)
            .right_hard
        else
            .right;
    } else if (input.down.left and !input.down.right) {
        self.body.position.x -= speed * delta_time;
        self.turn_time += delta_time;
        self.visual_state = if (self.turn_time >= hard_turn_delay)
            .left_hard
        else
            .left;
    } else {
        self.turn_time = 0.0;
        self.visual_state = .straight;
    }

    if (input.down.down)
        self.body.position.y += speed * delta_time;

    if (input.down.up)
        self.body.position.y -= speed * delta_time;
}
