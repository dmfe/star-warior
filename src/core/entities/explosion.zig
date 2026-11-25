const std = @import("std");
const common = @import("common");

const Vec2 = common.Vec2;
const Color = common.Color;
const Random = common.Random;

pub const max_particles = 24;

pub const Particle = struct {
    position: Vec2,
    velocity: Vec2,
    radius: f32,
    age: f32 = 0.0,
    lifetime: f32,
    color: Color,

    pub fn update(
        self: *Particle,
        delta_time: f32,
    ) void {
        self.age += delta_time;

        self.position.x += self.velocity.x * delta_time;
        self.position.y += self.velocity.y * delta_time;

        const drag = @max(0.0, 1.0 - 2.0 * delta_time);
        self.velocity.x *= drag;
        self.velocity.y *= drag;
    }

    pub fn expired(self: *const Particle) bool {
        return self.age >= self.lifetime;
    }

    pub fn progress(self: *const Particle) f32 {
        return std.math.clamp(
            self.age / self.lifetime,
            0.0,
            1.0,
        );
    }
};

const Self = @This();
particles: [max_particles]Particle,
particle_count: usize,
age: f32 = 0.0,
lifetime: f32,

pub fn init(
    random: *Random,
    position: Vec2,
    source_size: f32,
    color: Color,
) Self {
    var explosion: Self = .{
        .particles = undefined,
        .particle_count = max_particles,
        .lifetime = 0.8,
    };

    for (
        explosion.particles[0..explosion.particle_count]
    ) |*particle| {
        const angle = random.genFloatRange(
            0.0,
            std.math.tau,
        );

        const speed = random.genFloatRange(
            source_size * 2.0,
            source_size * 6.0,
        );

        particle.* = .{
            .position = position,
            .velocity = .{
                .x = @cos(angle) * speed,
                .y = @sin(angle) * speed,
            },
            .radius = random.genFloatRange(1.5, 4.0),
            .lifetime = random.genFloatRange(0.35, explosion.lifetime),
            .color = color,
        };
    }

    return explosion;
}

pub fn update(
    self: *Self,
    delta_time: f32,
) void {
    self.age += delta_time;
    for (self.particles[0..self.particle_count]) |*particle| {
        if (!particle.expired())
            particle.update(delta_time);
    }
}

pub fn expired(self: *const Self) bool {
    return self.age >= self.lifetime;
}

