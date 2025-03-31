const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    Ensure_Minimal_Zig_Version() catch
        @panic("Zig 0.14.0 or higher is required for compilation!");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    Make_Client_Executable(b, target, optimize);
    Make_Server_Executable(b, target, optimize);

    // format source files
    const format_options = std.Build.Step.Fmt.Options{ .paths = &.{"src/"} };
    const performStep_format = b.addFmt(format_options);
    b.default_step.dependOn(&performStep_format.step);
}

/// Assert Zig 0.14.0 or higher
pub fn Ensure_Minimal_Zig_Version() !void {
    const current_version = builtin.zig_version;
    const minimum_version = std.SemanticVersion{
        .major = 0,
        .minor = 14,
        .patch = 0,
        .build = null,
        .pre = null,
    };
    switch (std.SemanticVersion.order(current_version, minimum_version)) {
        .lt => return error.OutdatedVersion,
        .eq => {},
        .gt => {},
    }
}

// does not require SDL
pub fn Make_Server_Executable(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const exe = b.addExecutable(.{
        .name = "server",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/server/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(exe);

    // unit testing
    const added_tests = b.addTest(.{ .root_source_file = b.path("src/server/tests.zig") });
    const performStep_test = b.addRunArtifact(added_tests);
    b.default_step.dependOn(&performStep_test.step);

    // run executable
    var run_step = b.step("run_server", "Run the server executable");
    const performStep_run = b.addRunArtifact(exe);
    if (b.args) |args|
        performStep_run.addArgs(args);
    run_step.dependOn(&performStep_run.step);
}

// requires SDL3 linking
pub fn Make_Client_Executable(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const exe = b.addExecutable(.{
        .name = "client",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/client/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.linkSystemLibrary("SDL3");
    exe.linkLibC();
    b.installArtifact(exe);

    // unit testing
    const added_tests = b.addTest(.{ .root_source_file = b.path("src/client/tests.zig") });
    const performStep_test = b.addRunArtifact(added_tests);
    b.default_step.dependOn(&performStep_test.step);

    // run executable
    var run_step = b.step("run_client", "Run the client executable");
    const performStep_run = b.addRunArtifact(exe);
    if (b.args) |args|
        performStep_run.addArgs(args);
    run_step.dependOn(&performStep_run.step);
}
