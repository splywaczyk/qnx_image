"""Module 5: Secure Boot Implementation"""
load("@score_toolchains_qnx//rules/fs:ifs.bzl", "qnx_ifs")

package(default_visibility = ["//visibility:public"])

qnx_ifs(
    name = "secure_boot_ifs",
    srcs = [
        "//module_common/apps/verify_boot:verify_boot",
        "//module_common/buildfiles:tools_build"
    ],
    out = "secure_boot.ifs",
    build_file = "//module_5/buildfiles:secure_boot_build",
    ext_repo_maping = {
        "BIN_PATH": "$(location //module_common/apps/verify_boot:verify_boot)",
    },
)

sh_binary(
    name = "run_qemu",
    srcs = ["run_qemu.sh"],
    args = [
        "$(location //module_5:secure_boot_ifs)",
    ],
    data = [
        "//module_5:secure_boot_ifs",
    ],
)
