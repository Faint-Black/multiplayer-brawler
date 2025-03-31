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

    var packet_buffer: [2048]u8 = undefined;
    var packet_size: usize = 0;

    while (true) {
        var active_connection: std.net.Server.Connection = undefined;

        // wait for connection
        std.debug.print("Listening...\n", .{});
        active_connection = try server_stream.accept();

        // wait for packet
        std.debug.print("Connection established, client sending data...\n", .{});
        packet_size = try active_connection.stream.readAtLeast(&packet_buffer, packet_buffer.len);

        // process data then restart connection
        std.debug.print("Packet contents = \n{{\n{s}\n}}\n\n", .{packet_buffer[0..packet_size]});
    }

    std.debug.print("Exiting.\n", .{});
}
