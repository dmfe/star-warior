const std = @import("std");
const app = @import("app");
const core = @import("core");
const common = @import("common");
const platform = @import("platform");
const settings_module = @import("settings");

const Input = core.Input;
const Random = common.Random;
const AppState = app.State;
const AppCommand = app.Command;
const Gameplay = app.Gameplay;
const Settings = settings_module.Settings;

pub const Config = struct {
    title: [:0]const u8,
    width: i32,
    height: i32,
    resizable: bool,
};

const Self = @This();
allocator: std.mem.Allocator,
random: Random,
settings: Settings,
state: AppState,
exit_required: bool = false,

pub fn init(config: Config) !Self {
    platform.initWindow(
        config.width,
        config.height,
        config.title,
        config.resizable
    );
    errdefer platform.closeWindow();

    return .{
        .allocator = std.heap.c_allocator,
        .random = Random.init(),
        .settings = .{},
        .state = .{
            .main_menu = .{},
        },
    };
}

pub fn deinit(self: *Self) void {
    self.state.deinit();
    platform.closeWindow();
}

pub fn run(self: *Self) !void {
    while (!platform.shouldClose() and !self.exit_required) {
        const input = Input.poll();

        const frame_time = platform.deltaTime();
        const delta_time = @min(frame_time, 0.1);
        const command: AppCommand = switch (self.state) {
            .main_menu => |*main_menu| main_menu.update(input),
            .gameplay => |*gameplay| try gameplay.update(
                input,
                delta_time,
                &self.settings,
            ),
        };

        try self.applyCommand(command);

        if (self.exit_required)
            break;

        platform.beginFrame();
        defer platform.endFrame();

        switch (self.state) {
            .main_menu => |*main_menu| try main_menu.draw(),
            .gameplay => |*gameplay| try gameplay.draw(&self.settings),
        }
    }

}

fn applyCommand(
    self: *Self,
    command: AppCommand,
) !void {
    switch (command) {
        .none => {},
        .start_game => {
            const gameplay = try Gameplay.init(
                self.allocator,
                self.random
            );
            self.state.deinit();
            self.state = .{
                .gameplay = gameplay,
            };
        },
        .return_to_menu => {
            self.state.deinit();
            self.state = .{
                .main_menu = .{},
            };
        },
        .exit => {
            self.exit_required = true;
        },
    }
}

