const std = @import("std");
const common = @import("common");
const Color = common.Color;
const Random = common.Random;
const Vec2 = common.Vec2;
const Enemy = @import("../entities/enemy.zig");
const EnemyParams = @import("enemy_params.zig");

const Self = @This();
enemy_params: EnemyParams,
colors: []Color,
next_generation_time: f64,

pub fn init(
    allocator: std.mem.Allocator,
    params: EnemyParams,
    source_colors: []const Color,
    current_time: f64,
) !Self {
    const own_colors = try allocator.dupe(Color, source_colors);
    errdefer allocator.free(own_colors);

    return .{
        .enemy_params = params,
        .colors = own_colors,
        .next_generation_time = current_time,
    };
}

pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    allocator.free(self.colors);
    self.colors = &.{};
}

pub fn spawn(
    self: *Self,
    allocator: std.mem.Allocator,
    random: *Random,
    enemies: *std.ArrayList(Enemy),
    screen_size: Vec2,
    current_time: f64,
) !void {
    const params = self.enemy_params;
    if (current_time > self.next_generation_time
        and random.intRangeAtMost(0, 99) >= params.generation_chance)
    {
        const size = random.genFloatRange(params.min_size, params.max_size);
        const enemy: Enemy = .{
            .body = .{
                .position = .{
                    .x = random.genFloatRange(size / 2.0, screen_size.x - size / 2.0),
                    .y = -size,
                },
                .size = size,
                .speed = random.genFloatRange(params.min_speed, params.max_speed),
                .color = random.randomColor(self.colors),
            },
            .score_value = @as(u32, @intFromFloat(size)),
        };
        try enemies.append(allocator, enemy);
        self.next_generation_time = current_time + params.generation_cooldown;
    }
}

