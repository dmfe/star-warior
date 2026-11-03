const Direction = @import("common").Direction;
const isKeyDown = @import("platform").isKeyDown;

const Self = @This();
left: bool = false,
right: bool = false,
up: bool = false,
down: bool = false,

pub fn poll() Self {
    return .{
        .left = isKeyDown(.left),
        .right = isKeyDown(.right),
        .up = isKeyDown(.up),
        .down = isKeyDown(.down),
    };
}

