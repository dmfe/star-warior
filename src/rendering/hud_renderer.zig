const std = @import("std");
const platform = @import("platform");
const core = @import("core");
const resources_module = @import("resources");

const Statistics = core.Statistics;
const SimulationView = core.SimulationView;
const Enemy = core.Enemy;

const ResourceManager = resources_module.ResourceManager;

const Self = @This();

pub fn init(
    resources: *const ResourceManager,
) Self {
    const shaders_count = resources.shaders.count();
    std.log.info("Init hud renderer. Shaders loaded: {}", .{shaders_count});
    return .{};
}

pub fn draw(
    self: *const Self,
    resources: *ResourceManager,
    statistics: *const Statistics,
    view: SimulationView,
) !void {
    _ = self;
    _ = resources;

    try drawFPS();
    try drawEnemiesCount(view.enemies);
    try drawStatistics(statistics.*);
}

fn drawFPS() !void {
    var buf: [32]u8 = undefined;
    const fps_text = try std.fmt.bufPrintSentinel(
        &buf,
        "FPS: {d}",
        .{ platform.getFPS() },
        0,
    );
    platform.drawText(fps_text, 10, 10, 20, .dark_green);
}

fn drawEnemiesCount(
    enemies: []const Enemy
) !void {
    var buf: [32]u8 = undefined;
    const enemies_count_text = try std.fmt.bufPrintSentinel(
        &buf,
        "Entities count: {d}",
        .{ enemies.len },
        0,
    );
    platform.drawText(enemies_count_text, 10, 40, 20, .dark_green);
}

fn drawStatistics(
    statistics: Statistics
) !void {
    var buf: [32]u8 = undefined;
    const screen_width = platform.screenWidth();
    const font_size: f32 = 20.0;

    const score_text = try std.fmt.bufPrintSentinel(
        &buf,
        "Score: {d}",
        .{ statistics.current_score },
        0,
    );
    const score_text_size = try platform.measureText(score_text, font_size);
    const score_text_x = @as(i32, @intFromFloat(screen_width / 2.0 - score_text_size.x / 2.0));
    const score_text_y = @as(i32, @intFromFloat(score_text_size.y * 1.2));
    platform.drawText(
        score_text,
        score_text_x,
        score_text_y,
        @as(i32, @intFromFloat(font_size)),
        .white
    );

    const max_score_text = try std.fmt.bufPrintSentinel(
        &buf,
        "Max Score: {d}",
        .{ statistics.max_score },
        0,
    );
    const max_score_text_size = try platform.measureText(max_score_text, font_size);
    const max_score_text_x = @as(i32, @intFromFloat(screen_width - (max_score_text_size.x * 1.2)));
    const max_score_text_y = @as(i32, @intFromFloat(max_score_text_size.y * 1.2));
    platform.drawText(
        max_score_text,
        max_score_text_x,
        max_score_text_y,
        @as(i32, @intFromFloat(font_size)),
        .white
    );
}

