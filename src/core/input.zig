const Button = @import("common").Button;
const isKeyDown = @import("platform").isKeyDown;
const isKeyPressed = @import("platform").isKeyPressed;

const Down = struct {
    left: bool = false,
    right: bool = false,
    up: bool = false,
    down: bool = false,
    space: bool = false,
};

const Pressed = struct {
    left: bool = false,
    right: bool = false,
    up: bool = false,
    down: bool = false,
    space: bool = false,
};

const Self = @This();
down: Down,
pressed: Pressed,

pub fn poll() Self {
    return .{
        .down = .{
            .left = isKeyDown(.left),
            .right = isKeyDown(.right),
            .up = isKeyDown(.up),
            .down = isKeyDown(.down),
            .space = isKeyDown(.space),
        },
        .pressed = .{
            .left = isKeyPressed(.left),
            .right = isKeyPressed(.right),
            .up = isKeyPressed(.up),
            .down = isKeyPressed(.down),
            .space = isKeyPressed(.space),
        },
    };
}

