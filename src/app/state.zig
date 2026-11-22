const MainMenu = @import("states/main_menu.zig");
const Gameplay = @import("states/gameplay.zig");

pub const State = union(enum) {
    main_menu: MainMenu,
    gameplay: Gameplay,

    pub fn deinit(self: *State) void {
        switch (self.*) {
            .main_menu => {},
            .gameplay => |*gameplay| gameplay.deinit(),
        }
    }
};

