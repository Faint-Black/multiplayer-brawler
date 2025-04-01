//=============================================================//
//                                                             //
//                           MAIN                              //
//                                                             //
//   Requires Zig 0.14.0 and SDL3 for compilation.             //
//                                                             //
//=============================================================//

const std = @import("std");
const sdl = @import("render.zig");
const network = @import("network.zig");

pub fn main() void {
    var backing_allocator = std.heap.DebugAllocator(.{}).init;
    defer _ = backing_allocator.deinit();
    const global_allocator = backing_allocator.allocator();

    var nethandler = network.NetHandler.Init(global_allocator);
    defer nethandler.Deinit();
    nethandler.Connect_To_Server("127.0.0.1", 8080) catch {
        nethandler.Log_Error_And_Destroy("failed to connect to server");
    };

    var tick_counter: i32 = 0;
    var frame_counter: i32 = 0;

    var renderer = sdl.Renderer.Init("Brawler", 720, 480);
    while (renderer.is_running) {
        renderer.Update_Internal_Timers();
        while ((renderer.current_time > renderer.next_game_tick) and (renderer.loop_count < sdl.Renderer.max_frame_skip)) {
            // update input
            renderer.Handle_Events();
            // update game logic here
            foobar();

            renderer.next_game_tick += sdl.Renderer.tick_interval;
            renderer.loop_count += 1;
            std.debug.print("tick: {}\n", .{tick_counter});
            tick_counter += 1;
        }
        // update frame here
        renderer.Render_Frame();
        sdl.Renderer.Cap_Framerate();
        std.debug.print("frame: {}\n", .{frame_counter});
        frame_counter += 1;
    }
    renderer.Cleanup_And_Exit();
}

pub fn foobar() void {}
