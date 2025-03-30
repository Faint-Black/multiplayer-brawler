//=============================================================//
//                                                             //
//                           MAIN                              //
//                                                             //
//   Requires Zig 0.14.0 and SDL3 for compilation.             //
//                                                             //
//=============================================================//

const std = @import("std");
const builtin = @import("builtin");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub fn main() !void {
    // Initialize SDL3
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) == false) {
        std.log.err("SDL init failed!\n", .{});
        return;
    }

    // Create a window
    const window = sdl.SDL_CreateWindow("Hello, SDL3!", 800, 600, 0);
    if (window == null) {
        std.log.err("SDL window creation failed!", .{});
        sdl.SDL_Quit();
        return;
    }

    // Main event loop
    var event: sdl.SDL_Event = undefined;
    var running: bool = true;
    while (running) {
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                running = false;
            }
        }
    }

    // Clean up
    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
}
