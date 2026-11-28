const common = @import("raylib/common.zig");
const builtin = @import("builtin");

pub const initWindow = common.initWindow;
pub const closeWindow = common.closeWindow;
pub const shouldClose = common.shouldClose; 
pub const beginFrame = common.beginFrame;
pub const endFrame = common.endFrame;
pub const isKeyDown = common.isKeyDown;
pub const isKeyPressed = common.isKeyPressed;
pub const drawRect = common.drawRect;
pub const drawCircle = common.drawCircle;
pub const drawText = common.drawText;
pub const getFPS = common.getFPS;
pub const getTime = common.getTime;
pub const deltaTime = common.deltaTime;
pub const screenWidth = common.screenWidth;
pub const screenHeight = common.screenHeight;
pub const measureText = common.measureText; 

pub const Shader = @import("raylib/shader.zig");
pub const Texture = @import("raylib/texture.zig");

const storage = if (builtin.target.os.tag == .emscripten)
    @import("storage_web.zig")
else
    @import("storage_desktop.zig");
pub const loadMaxScore = storage.loadMaxScore;
pub const saveMaxScore = storage.saveMaxScore;

