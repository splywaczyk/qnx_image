"""Module 2: Extended System with Bash and Tools"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "extended_ifs",
    srcs = [
        "//02_hello_world/code/hello_world:hello_world",
        "//00_common/image_buildfiles:tools_build",
    ],
    out = "extended.ifs",
    build_file = "//02_hello_world/image_buildfiles:extended_build",
    # set BIN_PATH to the location of the hello_world binary
    # it will be used in the .build file
    ext_repo_maping = {
        "BIN_PATH": "$(location //02_hello_world/code/hello_world:hello_world)",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["scripts/run_qemu.sh"],
    args = [
        "$(location //02_hello_world:extended_ifs)",
    ],
    data = [
        "//02_hello_world:extended_ifs",
    ],
)
