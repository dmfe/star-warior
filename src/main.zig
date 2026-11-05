const App = @import("application.zig");

pub fn main() !void {
    var app = try App.init(.{
        .title = "Star Warior",
        .width = 800,
        .height = 600,
        .resizable = true,
    });
    defer app.deinit();
    try app.run();
}

