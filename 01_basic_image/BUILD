"""Module 1: Building Your First QNX Application"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "hello_world_ifs",
    srcs = [],
    out = "hello_world.ifs",
    build_file = "//01_basic_image/image_buildfiles:qnx_minimal_build",
)

sh_binary(
    name = "run_qemu",
    srcs = ["scripts/run_qemu.sh"],
    args = [
        "$(location //01_basic_image:hello_world_ifs)",
    ],
    data = [
        "//01_basic_image:hello_world_ifs",
    ],
)
