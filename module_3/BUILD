"""Module 3: IPC Communications"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "ipc_ifs",
    srcs = [
        "//module_common/apps/sender_receiver:receiver",
        "//module_common/apps/sender_receiver:sender1",
        "//module_common/apps/sender_receiver:sender2",
        "//module_common/buildfiles:tools_build"
    ],
    out = "ipc.ifs",
    build_file = "//module_3/buildfiles:ipc_build",
    ext_repo_maping = {
        "RECEIVER_PATH": "$(location //module_common/apps/sender_receiver:receiver)",
        "SENDER1_PATH": "$(location //module_common/apps/sender_receiver:sender1)",
        "SENDER2_PATH": "$(location //module_common/apps/sender_receiver:sender2)",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location //module_3:ipc_ifs)",
    ],
    data = [
        "//module_3:ipc_ifs",
    ],
)
