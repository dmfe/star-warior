const std = @import("std");
const platform = @import("platform");
const Player = @import("entities/player.zig");
const Enemy = @import("entities/enemy.zig");
const Projectile = @import("entities/projectile.zig");
const Statistics = @import("statistics.zig");

pub fn drawPlayer(player: *const Player) void {
    const body = player.body;
    platform.drawCircle(
        body.position.x,
        body.position.y,
        body.size / 2.0,
        body.color
    );
}

pub fn drawEnemies(enemies: []const Enemy) void {
    for (enemies) |e|
        platform.drawRect(
            e.body.position.x - e.body.size / 2.0,
            e.body.position.y - e.body.size / 2.0, 
            e.body.size,
            e.body.size,
            e.body.color
        );
}

pub fn drawProjectiles(projectiles: []const Projectile) void {
    for (projectiles) |p|
        platform.drawRect(
            p.body.position.x - p.body.size / 2.0,
            p.body.position.y - p.body.size / 2.0, 
            p.body.size,
            p.body.size,
            p.body.color
        );
}

pub fn drawFPS() !void {
    var buf: [32]u8 = undefined;
    const fps_text = try std.fmt.bufPrintSentinel(
        &buf,
        "FPS: {d}",
        .{ platform.getFPS() },
        0,
    );
    platform.drawText(fps_text, 10, 10, 20, .dark_green);
}

pub fn drawEnemiesCount(enemies: []const Enemy) !void {
    var buf: [32]u8 = undefined;
    const enemies_count_text = try std.fmt.bufPrintSentinel(
        &buf,
        "Entities count: {d}",
        .{ enemies.len },
        0,
    );
    platform.drawText(enemies_count_text, 10, 40, 20, .dark_green);
}

pub fn drawSimulationIsOverText(text: [:0]const u8) !void {
    const screen_width = platform.screenWidth();
    const screen_height = platform.screenHeight();
    const font_size: f32 = 50.0;
    const text_size = try platform.measureText(text, font_size);
    const x = @as(i32, @intFromFloat(screen_width / 2.0 - text_size.x / 2.0));
    const y = @as(i32, @intFromFloat(screen_height / 2.0));
    platform.drawText(
        text,
        x,
        y,
        @as(i32, @intFromFloat(font_size)),
        .red
    );
}

pub fn drawStatistics(statistics: Statistics) !void {
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

