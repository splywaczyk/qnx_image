"""QNX Toolchain Build Configuration"""

load(":qnx_toolchain.bzl", "cc_toolchain_config")

package(default_visibility = ["//visibility:public"])

# Workspace-relative path for qcc_wrapper (absolute path required by Bazel toolchain)
_WORKSPACE_ROOT = "/home/qnx/workspace/qnx"
_QCC_WRAPPER_PATH = _WORKSPACE_ROOT + "/qnx_sdp/wrappers/qcc_wrapper.sh"

# QNX x86_64 Toolchain Configuration
cc_toolchain_config(
    name = "qnx_x86_64_toolchain_config",
    toolchain_identifier = "qnx-x86_64",
    target_system_name = "qnx",
    target_cpu = "x86_64",
    target_libc = "qnx",
    compiler = "qcc",
    abi_version = "qnx8",
    abi_libc_version = "qnx8",
    compiler_path = _QCC_WRAPPER_PATH,
    linker_path = _QCC_WRAPPER_PATH,
    ar_path = "external/qnx_sdp/host/linux/x86_64/usr/bin/ntox86_64-ar",
    nm_path = "external/qnx_sdp/host/linux/x86_64/usr/bin/ntox86_64-nm",
    objdump_path = "external/qnx_sdp/host/linux/x86_64/usr/bin/ntox86_64-objdump",
    strip_path = "external/qnx_sdp/host/linux/x86_64/usr/bin/ntox86_64-strip",
)

# File groups for toolchain dependencies
filegroup(
    name = "qnx_x86_64_all_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@qnx_sdp//:x86_64_all_files",
    ],
)

filegroup(
    name = "qnx_x86_64_compiler_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@qnx_sdp//:x86_64_compiler_files",
    ],
)

filegroup(
    name = "qnx_x86_64_linker_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@qnx_sdp//:x86_64_linker_files",
    ],
)

# CC Toolchain for x86_64
cc_toolchain(
    name = "cc_toolchain_qnx_x86_64",
    all_files = ":qnx_x86_64_all_files",
    compiler_files = ":qnx_x86_64_compiler_files",
    dwp_files = ":qnx_x86_64_all_files",
    linker_files = ":qnx_x86_64_linker_files",
    objcopy_files = ":qnx_x86_64_all_files",
    strip_files = ":qnx_x86_64_all_files",
    supports_param_files = 0,
    supports_header_parsing = False,
    toolchain_config = ":qnx_x86_64_toolchain_config",
    toolchain_identifier = "qnx-x86_64",
)

# Toolchain declarations
toolchain(
    name = "toolchain_qnx_x86_64",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:qnx",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":cc_toolchain_qnx_x86_64",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
