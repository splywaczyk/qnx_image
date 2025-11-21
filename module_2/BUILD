"""Module 2: Extended System with Bash and Tools"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "extended_ifs",
    srcs = [
        "//module_common/apps/hello_world:hello_world",
        "//module_common/buildfiles:tools_build",
    ],
    out = "extended.ifs",
    build_file = "//module_2/buildfiles:extended_build",
    # set BIN_PATH to the location of the hello_world binary
    # it will be used in the .build file
    ext_repo_maping = {
        "BIN_PATH": "$(location //module_common/apps/hello_world:hello_world)",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location //module_2:extended_ifs)",
    ],
    data = [
        "//module_2:extended_ifs",
    ],
)
