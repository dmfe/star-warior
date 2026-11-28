const std = @import("std");
const app = @import("app");
const core = @import("core");
const common = @import("common");
const platform = @import("platform");
const settings_module = @import("settings");
const resources_module = @import("resources");

const Input = core.Input;

const Random = common.Random;
const Vec2 = common.Vec2;

const AppState = app.State;
const AppCommand = app.Command;
const Gameplay = app.Gameplay;
const MainMenu = app.MainMenu;

const Settings = settings_module.Settings;

const ResourceManager = resources_module.ResourceManager;

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
resources: ResourceManager,
exit_required: bool = false,

pub fn init(config: Config) !Self {
    const allocator = std.heap.c_allocator;

    platform.initWindow(
        config.width,
        config.height,
        config.title,
        config.resizable
    );
    errdefer platform.closeWindow();

    var resources = ResourceManager.init(allocator);
    errdefer resources.deinit();

    // loading resources
    _ = try resources.loadShader(
        "shader/starfield",
        "starfield.fs",
    );
    _ = try resources.loadTexture(
        "texture/player",
        "star-warior-sheet-128-480.png",
    );

    const main_menu = try MainMenu.init(&resources);

    return .{
        .allocator = allocator,
        .random = Random.init(),
        .settings = .{},
        .state = .{
            .main_menu = main_menu,
        },
        .resources = resources,
    };
}

pub fn deinit(self: *Self) void {
    self.state.deinit();
    self.resources.deinit();
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
                &self.settings,
                delta_time,
            ),
        };

        try self.applyCommand(command);

        if (self.exit_required)
            break;

        platform.beginFrame();
        defer platform.endFrame();

        const resolution: Vec2 = .{
            .x = platform.screenWidth(),
            .y = platform.screenHeight(),
        };
        switch (self.state) {
            .main_menu => |*main_menu| try main_menu.draw(
                &self.resources,
                resolution,
                @floatCast(platform.getTime()),
            ),
            .gameplay => |*gameplay| try gameplay.draw(
                &self.resources,
                &self.settings,
                resolution,
                @floatCast(platform.getTime()),
            ),
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
                self.random,
                &self.resources,
            );
            self.state.deinit();
            self.state = .{
                .gameplay = gameplay,
            };
        },
        .return_to_menu => {
            const main_menu = try MainMenu.init(
                &self.resources
            );
            self.state.deinit();
            self.state = .{
                .main_menu = main_menu,
            };
        },
        .exit => {
            self.exit_required = true;
        },
    }
}

