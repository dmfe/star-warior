pub const OpenLayer = enum {
    inventory,
    pause_menu,
    settings,
};

pub const Command = union(enum) {
    none,
    push: OpenLayer,
    pop,
    return_to_menu,
    restart_game,
    exit_application,
};

