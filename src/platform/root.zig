const raylib = @import("raylib.zig");
const builtin = @import("builtin");

pub const initWindow = raylib.initWindow;
pub const closeWindow = raylib.closeWindow;
pub const shouldClose = raylib.shouldClose; 
pub const beginFrame = raylib.beginFrame;
pub const endFrame = raylib.endFrame;
pub const isKeyDown = raylib.isKeyDown;
pub const isKeyPressed = raylib.isKeyPressed;
pub const drawRect = raylib.drawRect;
pub const drawCircle = raylib.drawCircle;
pub const drawText = raylib.drawText;
pub const getFPS = raylib.getFPS;
pub const getTime = raylib.getTime;
pub const deltaTime = raylib.deltaTime;
pub const screenWidth = raylib.screenWidth;
pub const screenHeight = raylib.screenHeight;
pub const measureText = raylib.measureText; 

const storage = if (builtin.target.os.tag == .emscripten)
    @import("storage_web.zig")
else
    @import("storage_desktop.zig");
pub const loadMaxScore = storage.loadMaxScore;
pub const saveMaxScore = storage.saveMaxScore;

