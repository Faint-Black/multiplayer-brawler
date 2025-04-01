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

// TODO: what is the best paradigm for error propagation?
// TODO: implement tick delay system and framerate cap.

pub fn main() void {
    var backing_allocator = std.heap.DebugAllocator(.{}).init;
    defer _ = backing_allocator.deinit();
    const global_allocator = backing_allocator.allocator();

    var nethandler = network.NetHandler.Init(global_allocator);
    defer nethandler.Deinit();
    nethandler.Connect_To_Server("127.0.0.1", 8080) catch |err| {
        nethandler.Log_Error_And_Destroy("failed to connect to address", @errorName(err));
    };

    _ = nethandler.Send_Message("Hello\n") catch |err| {
        nethandler.Log_Error_And_Destroy("failed to write to socket", @errorName(err));
    };
    _ = nethandler.Send_Message("from the other side!\n") catch |err| {
        nethandler.Log_Error_And_Destroy("failed to write to socket", @errorName(err));
    };

    var renderer = sdl.Renderer.Init("Brawler", 720, 480);
    while (renderer.is_running) {
        renderer.Handle_Events();
        renderer.Render_Frame();
        renderer.Update_State();
    }
    renderer.Cleanup_And_Exit();
}
