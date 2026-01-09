"""Module 3: IPC Communications"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "ipc_ifs",
    srcs = [
        "//03_ipc/code/receiver:receiver",
        "//03_ipc/code/sender_a:sender_a",
        "//03_ipc/code/sender_b:sender_b",
        "//00_common/image_buildfiles:tools_build",
    ],
    out = "ipc.ifs",
    build_file = "//03_ipc/image_buildfiles:ipc_build",
    ext_repo_maping = {
        "RECEIVER_PATH": "$(location //03_ipc/code/receiver:receiver)",
        "SENDER1_PATH": "$(location //03_ipc/code/sender_a:sender_a)",
        "SENDER2_PATH": "$(location //03_ipc/code/sender_b:sender_b)",
    },
)

qnx_ifs(
    name = "ipc_secure_ifs",
    srcs = [
        "//03_ipc/code/receiver:receiver",
        "//03_ipc/code/sender_a:sender_a",
        "//03_ipc/code/sender_b:sender_b",
        "//03_ipc/secpol:ipc_policy_compile",
        "//00_common/image_buildfiles:tools_build",
    ],
    out = "ipc_secure.ifs",
    build_file = "//03_ipc/image_buildfiles:ipc_secure_build",
    ext_repo_maping = {
        "RECEIVER_PATH": "$(location //03_ipc/code/receiver:receiver)",
        "SENDER1_PATH": "$(location //03_ipc/code/sender_a:sender_a)",
        "SENDER2_PATH": "$(location //03_ipc/code/sender_b:sender_b)",
        "POLICY_PATH": "$(location //03_ipc/secpol:ipc_policy_compile)",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["scripts/run_qemu.sh"],
    args = [
        "$(location //03_ipc:ipc_ifs)",
    ],
    data = [
        "//03_ipc:ipc_ifs",
    ],
)

sh_binary(
    name = "run_qemu_secure",
    srcs = ["scripts/run_qemu.sh"],
    args = [
        "$(location //03_ipc:ipc_secure_ifs)",
    ],
    data = [
        "//03_ipc:ipc_secure_ifs",
    ],
)
