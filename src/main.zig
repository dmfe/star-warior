const std = @import("std");
const rl = @import("raylib");

const Shape = struct {
    x: f32,
    y: f32,
    size: f32,
    speed: f32,
};

fn genFloatRange(rand: std.Random, at: f32, most: f32) f32 {
    return at + rand.float(f32) * (most - at);
}

pub fn main() !void {
    const width = 800;
    const height = 600;

    var threaded: std.Io.Threaded = .init_single_threaded;
    const io = threaded.io();
    const timestamp = std.Io.Clock.now(.real, io);
    const seed: u64 = @intCast(timestamp.toNanoseconds());
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    rl.setConfigFlags(.{ .window_resizable = true });
    rl.initWindow(width, height, "Star Warior");
    defer rl.closeWindow();

    const allocator = std.heap.c_allocator;

    // Game objects
    const enemy_min_speed: f32 = 50.0;
    const enemy_max_speed: f32 = 150.0;
    const enemy_min_size: f32 = 16.0;
    const enemy_max_size: f32 = 64.0;

    var enemies: std.ArrayList(Shape) = .empty;
    defer enemies.deinit(allocator);
    var player: Shape = .{
        .x = @as(f32, @floatFromInt(rl.getScreenWidth())) / 2.0,
        .y = @as(f32, @floatFromInt(rl.getScreenHeight())) / 2.0,
        .size = 16.0,
        .speed = 400.0,
    };

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.dark_purple);

        const delta_time: f32 = rl.getFrameTime();
        const screen_widht: f32 = @floatFromInt(rl.getScreenWidth());
        const screen_height: f32 = @floatFromInt(rl.getScreenHeight());

        if (rl.isKeyDown(.right)) player.x += player.speed * delta_time;
        if (rl.isKeyDown(.left)) player.x -= player.speed * delta_time;
        if (rl.isKeyDown(.down)) player.y += player.speed * delta_time;
        if (rl.isKeyDown(.up)) player.y -= player.speed * delta_time;

        // Clamp player coordinates to be within the screen
        player.x = std.math.clamp(player.x, player.size, screen_widht - player.size);
        player.y = std.math.clamp(player.y, player.size, screen_height - player.size);

        // Generate a new enemy
        if (rand.intRangeAtMost(u8, 0, 99) >= 85) {
            const size = genFloatRange(rand, enemy_min_size, enemy_max_size);
            try enemies.append(allocator, .{
                .x = genFloatRange(rand, size / 2.0, screen_widht - size / 2.0),
                .y = -size,
                .size = size,
                .speed = genFloatRange(rand, enemy_min_speed, enemy_max_speed),
            });
        }

        // Move enemies
        for (enemies.items) |*enemy|
            enemy.y += enemy.speed * delta_time;

        // Remove enemies below bottom of the screen
        var retain_enemy_ind: usize = 0;
        for (enemies.items) |enemy| {
            if (enemy.y < screen_height + enemy.size) {
                enemies.items[retain_enemy_ind] = enemy;
                retain_enemy_ind += 1;
            }
        }
        enemies.shrinkRetainingCapacity(retain_enemy_ind);

        // Drawing objects
        rl.drawCircleV(.{ .x = player.x, .y = player.y }, player.size, .yellow);
        for (enemies.items) |enemy|
            rl.drawRectangleRec(.{
                .x = enemy.x - enemy.size / 2.0,
                .y = enemy.y - enemy.size / 2.0,
                .width = enemy.size,
                .height = enemy.size,
            }, .red);

        // Drawing Info
        var buf: [32]u8 = undefined;

        const fps_text = try std.fmt.bufPrintSentinel(
            &buf,
            "FPS: {d}",
            .{ rl.getFPS() },
            0,
        );
        rl.drawText(fps_text, 10, 10, 20, .dark_green);

        const enemies_cout_text = try std.fmt.bufPrintSentinel(
            &buf,
            "Enemies count: {d}",
            .{ enemies.items.len },
            0,
        );
        rl.drawText(enemies_cout_text, 10, 40, 20, .dark_green);
    }
}

