"""Module 4: Security Policies and Access Control"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "ipc_secure_ifs",
    srcs = [
        "//module_common/apps/receiver:receiver",
        "//module_common/apps/sender_a:sender_a",
        "//module_common/apps/sender_b:sender_b",
        "//module_4/secpol:ipc_policy_compile",
        "//module_common/buildfiles:tools_build"
    ],
    out = "ipc_secure.ifs",
    build_file = "//module_4/buildfiles:ipc_secure_build",
    ext_repo_maping = {
        "RECEIVER_PATH": "$(location //module_common/apps/receiver:receiver)",
        "SENDER1_PATH": "$(location //module_common/apps/sender_a:sender_a)",
        "SENDER2_PATH": "$(location //module_common/apps/sender_b:sender_b)",
        "POLICY_PATH": "$(location //module_4/secpol:ipc_policy_compile)",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location //module_4:ipc_secure_ifs)",
    ],
    data = [
        "//module_4:ipc_secure_ifs",
    ],
)
