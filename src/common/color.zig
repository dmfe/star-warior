pub const Self = @This();
r: u8,
g: u8,
b: u8,
a: u8 = 255,

// Basic colors
pub const black: Self = .{ .r = 0,   .g = 0,   .b = 0,   .a = 255 };
pub const white: Self = .{ .r = 255, .g = 255, .b = 255, .a = 255 };
pub const red:   Self = .{ .r = 255, .g = 0,   .b = 0,   .a = 255 };
pub const green: Self = .{ .r = 0,   .g = 255, .b = 0,   .a = 255 };
pub const blue:  Self = .{ .r = 0,   .g = 0,   .b = 255, .a = 255 };

// Secondary colors
pub const yellow:  Self = .{ .r = 255, .g = 255, .b = 0,   .a = 255 };
pub const cyan:    Self = .{ .r = 0,   .g = 255, .b = 255, .a = 255 };
pub const magenta: Self = .{ .r = 255, .g = 0,   .b = 255, .a = 255 };

// Grays
pub const gray:       Self = .{ .r = 128, .g = 128, .b = 128, .a = 255 };
pub const light_gray: Self = .{ .r = 211, .g = 211, .b = 211, .a = 255 };
pub const dark_gray:  Self = .{ .r = 64,  .g = 64,  .b = 64,  .a = 255 };
pub const silver:     Self = .{ .r = 192, .g = 192, .b = 192, .a = 255 };

// Common web colors
pub const orange:     Self = .{ .r = 255, .g = 165, .b = 0,   .a = 255 };
pub const purple:     Self = .{ .r = 128, .g = 0,   .b = 128, .a = 255 };
pub const pink:       Self = .{ .r = 255, .g = 192, .b = 203, .a = 255 };
pub const brown:      Self = .{ .r = 165, .g = 42,  .b = 42,  .a = 255 };
pub const gold:       Self = .{ .r = 255, .g = 215, .b = 0,   .a = 255 };
pub const navy:       Self = .{ .r = 0,   .g = 0,   .b = 128, .a = 255 };
pub const teal:       Self = .{ .r = 0,   .g = 128, .b = 128, .a = 255 };
pub const olive:      Self = .{ .r = 128, .g = 128, .b = 0,   .a = 255 };
pub const maroon:     Self = .{ .r = 128, .g = 0,   .b = 0,   .a = 255 };
pub const lime:       Self = .{ .r = 0,   .g = 255, .b = 0,   .a = 255 };
pub const aqua:       Self = .{ .r = 0,   .g = 255, .b = 255, .a = 255 };
pub const fuchsia:    Self = .{ .r = 255, .g = 0,   .b = 255, .a = 255 };
pub const dark_green: Self = .{ .r = 0,   .g = 117, .b = 44,  .a = 255 };

