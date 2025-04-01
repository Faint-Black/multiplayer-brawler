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
    /// tick/frame tracking variables and constants
    // should be good enough for this game
    pub const ticks_per_second = 20;
    // standard
    pub const frames_per_second = 60;
    // 50ms per tick
    pub const tick_interval = 1000 / ticks_per_second;
    // 16ms per frame
    pub const frame_interval = 1000 / frames_per_second;
    // cap amount of ticks processed in one frame
    pub const max_frame_skip = 5;
    // for handling multiple ticks in one go, if needed
    loop_count: i32 = undefined,
    // target time for when the next game tick should occur
    next_game_tick: u64 = undefined,
    // current elapsed time
    current_time: u64 = undefined,

    /// internal SDL variables
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,

    /// core variables
    window_width: i32 = undefined,
    window_height: i32 = undefined,
    is_running: bool = false,

    /// Initialize SDL3 and struct variables
    pub fn Init(title: [*:0]const u8, width: i32, height: i32) Renderer {
        var result = Renderer{};

        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) == false)
            Log_Error_And_Quit("init failed!");
        if (sdl.SDL_CreateWindowAndRenderer(title, width, height, 0x0, &result.window, &result.renderer) == false)
            Log_Error_And_Quit("window/renderer creation failed!");

        result.window_width = width;
        result.window_height = height;
        result.is_running = true;

        result.next_game_tick = sdl.SDL_GetTicks();

        return result;
    }

    /// Update tick-by-tick logic, this is where the tick-rate is limited
    pub fn Update_Internal_Timers(this: *Renderer) void {
        this.loop_count = 0;
        this.current_time = sdl.SDL_GetTicks();
    }

    /// Process polled queued events
    pub fn Handle_Events(this: *Renderer) void {
        var event: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                this.is_running = false;
            }
            if (event.type == sdl.SDL_EVENT_KEY_DOWN) {
                switch (event.key.key) {
                    sdl.SDLK_W => {
                        std.debug.print("UP\n", .{});
                    },
                    sdl.SDLK_S => {
                        std.debug.print("DOWN\n", .{});
                    },
                    else => {},
                }
            }
        }
    }

    /// Renders the frame
    pub fn Render_Frame(this: *Renderer) void {
        // frame clear with white color
        if (sdl.SDL_SetRenderDrawColor(this.renderer, 0xE0, 0xE0, 0xE0, 255) == false)
            Log_Error_And_Quit("set render draw color failed!");
        if (sdl.SDL_RenderClear(this.renderer) == false)
            Log_Error_And_Quit("render clearing failed!");

        // draw red rectangle
        if (sdl.SDL_SetRenderDrawColor(this.renderer, 0xFF, 0x10, 0x10, 255) == false)
            Log_Error_And_Quit("set render draw color failed!");
        const rect = sdl.SDL_FRect{
            .x = 0,
            .y = 0,
            .w = 40.0,
            .h = 40.0,
        };
        if (sdl.SDL_RenderFillRect(this.renderer, &rect) == false)
            Log_Error_And_Quit("failed to render rect!");

        // flush frame
        if (sdl.SDL_RenderPresent(this.renderer) == false)
            Log_Error_And_Quit("render frame failed!");
    }

    /// Cap framerate
    pub fn Cap_Framerate() void {
        sdl.SDL_Delay(frame_interval);
    }

    /// Deinits the struct then kills the program
    pub fn Cleanup_And_Exit(this: Renderer) void {
        std.debug.print("Gracefully exiting...\n", .{});
        sdl.SDL_DestroyWindow(this.window);
        sdl.SDL_DestroyRenderer(this.renderer);
        sdl.SDL_Quit();
    }

    /// Automatically handles error logging
    fn Log_Error_And_Quit(msg: []const u8) void {
        std.log.err("SDL error: {s}\nError code: \"{s}\"", .{ msg, sdl.SDL_GetError() });
        sdl.SDL_Quit();
    }
};
