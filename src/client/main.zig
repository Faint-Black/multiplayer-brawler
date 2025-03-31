//=============================================================//
//                                                             //
//                           MAIN                              //
//                                                             //
//   Requires Zig 0.14.0 and SDL3 for compilation.             //
//                                                             //
//=============================================================//

const sdl = @import("render.zig");

pub fn main() !void {
    var renderer = sdl.Renderer.Init("Brawler", 720, 480);

    while (renderer.is_running) {
        renderer.Handle_Events();
        renderer.Render_Frame();
    }

    renderer.Cleanup_And_Exit();
}
