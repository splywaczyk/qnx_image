"""Module 1: Building Your First QNX Application"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "hello_world_ifs",
    srcs = [],
    out = "hello_world.ifs",
    build_file = "//module_1/buildfiles:qnx_minimal_build",
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location //module_1:hello_world_ifs)",
    ],
    data = [
        "//module_1:hello_world_ifs",
    ],
)
