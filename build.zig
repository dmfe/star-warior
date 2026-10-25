const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Dependencies
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
        .config = "-fno-sanitize=undefined -fno-lto",
    });
    const raylib = raylib_dep.module("raylib");
    const raylib_artifact = raylib_dep.artifact("raylib");

    const exe_name = b.option(
        []const u8,
        "exe_name",
        "Name of the executable",
    ) orelse "star-warior";
    
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_mod.addImport("raylib", raylib);

    const run_step = b.step("run", "Run star-warior application");

    if (target.query.os_tag == .emscripten) {
        const wasm = b.addLibrary(.{
            .name = exe_name,
            .root_module = exe_mod,
        });

        const emcc_cmd = b.addSystemCommand(&.{ "emcc" });
        emcc_cmd.addFileArg(wasm.getEmittedBin());
        emcc_cmd.addFileArg(raylib_artifact.getEmittedBin());
        emcc_cmd.addArgs(&.{
            "-sUSE_GLFW=3",
            "-sASYNCIFY",
            "-sFULL-ES3=1",
        });
        emcc_cmd.addArg("--shell-file");
        emcc_cmd.addFileArg(b.path("src/web/shell.html"));
        emcc_cmd.step.dependOn(&wasm.step);
        emcc_cmd.step.dependOn(&raylib_artifact.step);
        
        const html_filename = try std.fmt.allocPrint(b.allocator, "{s}.html", .{ wasm.name });
        const output_file = emcc_cmd.addPrefixedOutputFileArg("-o", html_filename);
        const install_html = b.addInstallFileWithDir(
            output_file,
            .{ .custom = "web" },
            html_filename,
        );
        b.getInstallStep().dependOn(&install_html.step);

        const cache_dir = output_file.dirname();
        const js_filename = b.fmt("{s}.js", .{ wasm.name });
        const wasm_filename = b.fmt("{s}.wasm", .{ wasm.name });

        const js_lazy = cache_dir.path(b, js_filename);
        const install_js = b.addInstallFileWithDir(
            js_lazy,
            .{ .custom = "web" },
            js_filename,
        );
        b.getInstallStep().dependOn(&install_js.step);

        const wasm_lazy = cache_dir.path(b, wasm_filename);
        const install_wasm = b.addInstallFileWithDir(
            wasm_lazy,
            .{ .custom = "web" },
            wasm_filename,
        );
        b.getInstallStep().dependOn(&install_wasm.step);

        const emrun_cmd = b.addSystemCommand(&.{ "emrun" });
        emrun_cmd.addArg(b.fmt("zig-out/web/{s}", .{ html_filename }));
        emrun_cmd.step.dependOn(&install_html.step);
        emrun_cmd.step.dependOn(&install_js.step);
        emrun_cmd.step.dependOn(&install_wasm.step);
        run_step.dependOn(&emrun_cmd.step);
    } else {
        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_module = exe_mod,
        });
        exe.root_module.linkLibrary(raylib_artifact);

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        run_cmd.addPassthruArgs();
        run_step.dependOn(&run_cmd.step);
    }
}

