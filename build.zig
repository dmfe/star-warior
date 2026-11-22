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

    const common = b.addLibrary(.{
        .name = "common",
        .root_module = b.addModule("common", .{
            .root_source_file = b.path("src/common/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const settings = b.addLibrary(.{
        .name = "settings",
        .root_module = b.addModule("settings", .{
            .root_source_file = b.path("src/settings/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const platform = b.addLibrary(.{
        .name = "platform",
        .root_module = b.addModule("platform", .{
            .root_source_file = b.path("src/platform/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    platform.root_module.addImport("common", common.root_module);
    platform.root_module.addImport("raylib", raylib);

    const core = b.addLibrary(.{
        .name = "core",
        .root_module = b.addModule("core", .{
            .root_source_file = b.path("src/core/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    core.root_module.addImport("common", common.root_module);
    core.root_module.addImport("platform", platform.root_module);

    const gameplay = b.addLibrary(.{
        .name = "gameplay",
        .root_module = b.addModule("gameplay", .{
            .root_source_file = b.path("src/gameplay/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    gameplay.root_module.addImport("common", common.root_module);
    gameplay.root_module.addImport("core", core.root_module);
    gameplay.root_module.addImport("settings", settings.root_module);

    const app = b.addLibrary(.{
        .name = "app",
        .root_module = b.addModule("app", .{
            .root_source_file = b.path("src/app/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    app.root_module.addImport("common", common.root_module);
    app.root_module.addImport("core", core.root_module);
    app.root_module.addImport("gameplay", gameplay.root_module);
    app.root_module.addImport("settings", settings.root_module);

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
    exe_mod.addImport("platform", platform.root_module);
    exe_mod.addImport("common", common.root_module);
    exe_mod.addImport("core", core.root_module);
    exe_mod.addImport("app", app.root_module);
    exe_mod.addImport("settings", settings.root_module);

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
        emcc_cmd.addArg("--js-library");
        emcc_cmd.addFileArg(b.path("src/web/storage.js"));
        emcc_cmd.addArg("--shell-file");
        emcc_cmd.addFileArg(b.path("src/web/shell.html"));
        emcc_cmd.addArgs(&.{
            "--preload-file",
            "assets@/assets",
        });
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
        const js_filename = b.fmt("{s}.js", .{wasm.name});
        const wasm_filename = b.fmt("{s}.wasm", .{wasm.name});
        const data_filename = b.fmt("{s}.data", .{wasm.name});

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

        const data_lazy = cache_dir.path(b, data_filename);
        const install_data = b.addInstallFileWithDir(
            data_lazy,
            .{ .custom = "web" },
            data_filename,
        );
        b.getInstallStep().dependOn(&install_data.step);

        const emrun_cmd = b.addSystemCommand(&.{ "emrun" });
        emrun_cmd.addArg(b.fmt("zig-out/web/{s}", .{ html_filename }));
        emrun_cmd.step.dependOn(&install_html.step);
        emrun_cmd.step.dependOn(&install_js.step);
        emrun_cmd.step.dependOn(&install_wasm.step);
        emrun_cmd.step.dependOn(&install_data.step);
        run_step.dependOn(&emrun_cmd.step);
    } else {
        const install_assets = b.addInstallDirectory(.{
            .source_dir = b.path("assets"),
            .install_dir = .bin,
            .install_subdir = "assets",
        });

        b.getInstallStep().dependOn(&install_assets.step);

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
