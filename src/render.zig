//=============================================================//
//                                                             //
//                          RENDERER                           //
//                                                             //
//   Deal with everything SDL3 related. Including rendering    //
//  the frame, handling events, and exiting the program.       //
//                                                             //
//=============================================================//

const std = @import("std");
const builtin = @import("builtin");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
});

pub const Renderer = struct {
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,
    is_running: bool = true,

    /// Initialize SDL3 and struct variables
    pub fn Init(title: [*:0]const u8, width: i32, height: i32) Renderer {
        var result = Renderer{};

        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) == false)
            Log_Error_And_Quit("init failed!");
        if (sdl.SDL_CreateWindowAndRenderer(title, width, height, 0x0, &result.window, &result.renderer) == false)
            Log_Error_And_Quit("window/renderer creation failed!");

        return result;
    }

    /// Process polled queued events
    pub fn Handle_Events(this: *Renderer) void {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                this.is_running = false;
            }
        }
    }

    /// Renders the frame
    pub fn Render_Frame(this: *Renderer) void {
        if (sdl.SDL_SetRenderDrawColor(this.renderer, 0xFF, 0x00, 0x00, 255) == false)
            Log_Error_And_Quit("set render draw color failed!");
        if (sdl.SDL_RenderClear(this.renderer) == false)
            Log_Error_And_Quit("render clearing failed!");
        if (sdl.SDL_RenderPresent(this.renderer) == false)
            Log_Error_And_Quit("render frame failed!");
    }

    /// Deinits the struct then kills the program
    pub fn Cleanup_And_Exit(this: Renderer) void {
        std.debug.print("Gracefully exiting...\n", .{});
        sdl.SDL_DestroyWindow(this.window);
        sdl.SDL_DestroyRenderer(this.renderer);
        sdl.SDL_Quit();
    }

    /// Automatically handles logging
    fn Log_Error_And_Quit(msg: []const u8) void {
        std.log.err("SDL error: {s}\nError code: \"{s}\"", .{ msg, sdl.SDL_GetError() });
        sdl.SDL_Quit();
    }
};
