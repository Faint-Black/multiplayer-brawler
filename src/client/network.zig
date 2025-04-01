const std = @import("std");

pub const status = enum {
    not_connected,
    successfully_connected,
    failed_connection,
};

pub const NetHandler = struct {
    allocator: std.mem.Allocator = undefined,
    ipv4: ?[]u8 = null,
    port: u16 = undefined,
    packet_buffer: [4096]u8 = undefined,
    packet_len: usize = 0,
    connection_stream: ?std.net.Stream = null,

    /// not responsible for establishing connection
    pub fn Init(allocator: std.mem.Allocator) NetHandler {
        var result = NetHandler{};
        result.allocator = allocator;
        return result;
    }

    /// closing the stream automatically terminates the connection
    pub fn Deinit(this: *NetHandler) void {
        if (this.connection_stream) |stream| {
            stream.close();
            this.connection_stream = null;
        }
        if (this.ipv4) |memory| {
            this.allocator.free(memory);
            this.ipv4 = null;
        }
    }

    /// fetch TCP connection socket
    pub fn Connect_To_Server(this: *NetHandler, ipv4: []const u8, port: u16) !void {
        if (this.connection_stream != null)
            Log_Error("attempted to connect while already connected", null);

        this.ipv4 = this.allocator.dupe(u8, ipv4) catch |err| {
            Log_Error("allocator failure", @errorName(err));
            return err;
        };
        this.port = port;
        this.connection_stream = std.net.tcpConnectToHost(std.heap.smp_allocator, ipv4, port) catch |err| {
            Log_Error("failed to establish TCP connection", @errorName(err));
            return err;
        };
    }

    /// returns amount of bytes written
    pub fn Send_Message(this: *NetHandler, msg: []const u8) !usize {
        var bytes_written: usize = undefined;
        if (this.connection_stream) |stream| {
            bytes_written = stream.write(msg) catch |err| {
                Log_Error("failed to write to socket", @errorName(err));
                return err;
            };
            if (bytes_written == 0) {
                Log_Error("written zero bytes to socket", null);
                return error.ZeroBytesWritten;
            }
        } else {
            Log_Error("attempted to write with no active connection", null);
            return error.NoConnection;
        }
        return bytes_written;
    }

    /// backtrace log
    pub fn Log_Error(msg: []const u8, error_msg: ?[]const u8) void {
        if (error_msg) |error_message| {
            std.log.err("NETWORK error: {s}: \"{s}\"", .{ msg, error_message });
        } else {
            std.log.err("NETWORK error: {s}", .{msg});
        }
    }

    /// crash and burn
    pub fn Log_Error_And_Destroy(this: *NetHandler, msg: []const u8) void {
        std.log.err("fatal NETWORK error: {s}, killing handler...", .{msg});
        this.Deinit();
    }
};
