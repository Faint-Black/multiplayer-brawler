//=============================================================//
//                                                             //
//                           MAIN                              //
//                                                             //
//   Requires Zig 0.14.0 for compilation.                      //
//                                                             //
//=============================================================//

const std = @import("std");

pub fn main() !void {
    var server_address = try std.net.Address.parseIp4("127.0.0.1", 8080);
    var server_stream = try server_address.listen(.{ .reuse_address = true });
    defer server_stream.deinit();

    var packet_buffer: [4096]u8 = undefined;
    var packet_size: usize = 0;

    while (true) {
        var active_connection: std.net.Server.Connection = undefined;

        std.debug.print("Listening...\n", .{});
        active_connection = server_stream.accept() catch |err| {
            std.log.err("Connection failed!: \"{s}\"", .{@errorName(err)});
            break;
        };

        std.debug.print("Connection established, client sending data...\n", .{});
        while (true) {
            packet_size = active_connection.stream.read(&packet_buffer) catch |err| {
                std.log.err("Packet reading failed!: \"{s}\"", .{@errorName(err)});
                break;
            };
            if (packet_size == 0) {
                std.debug.print("Connection closing.\n", .{});
                break;
            }
            std.debug.print("Packet contents:\n{s}\n", .{packet_buffer[0..packet_size]});
        }
    }

    std.debug.print("Exiting abruptly...\n", .{});
}
