const Simulation = @import("core").Simulation;
const Settings = @import("settings").Settings;

pub const Context = struct {
    simulation: *Simulation,
    settings: *Settings,
};

