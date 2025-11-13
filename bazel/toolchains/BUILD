"""QNX Toolchain Build Configuration"""

load(":qnx_toolchain.bzl", "cc_toolchain_config")
load("//qnx_sdp:variables.bzl", "QNX_SDP_NAME")

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
    ar_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntox86_64-ar",
    nm_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntox86_64-nm",
    objdump_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntox86_64-objdump",
    strip_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntox86_64-strip",
    compile_flags = [
        "-V",
        "gcc_ntox86_64",
        "-std=gnu++14",
    ],
    link_flags = [
        "-V",
        "gcc_ntox86_64",
    ],
    cxx_builtin_include_directories = [
        "external/" + QNX_SDP_NAME + "/target/qnx/x86_64/usr/include",
        "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx8.0.0/12.2.0/include",
    ],
)

# QNX aarch64 Toolchain Configuration
cc_toolchain_config(
    name = "qnx_aarch64_toolchain_config",
    toolchain_identifier = "qnx-aarch64",
    target_system_name = "qnx",
    target_cpu = "aarch64",
    target_libc = "qnx",
    compiler = "qcc",
    abi_version = "qnx8",
    abi_libc_version = "qnx8",
    compiler_path = _QCC_WRAPPER_PATH,
    linker_path = _QCC_WRAPPER_PATH,
    ar_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntoaarch64-ar",
    nm_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntoaarch64-nm",
    objdump_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntoaarch64-objdump",
    strip_path = "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/bin/ntoaarch64-strip",
    compile_flags = [
        "-V",
        "gcc_ntoaarch64le",
        "-std=gnu++14",
    ],
    link_flags = [
        "-V",
        "gcc_ntoaarch64le",
    ],
    cxx_builtin_include_directories = [
        "external/" + QNX_SDP_NAME + "/target/qnx/aarch64le/usr/include",
        "external/" + QNX_SDP_NAME + "/host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx8.0.0/12.2.0/include",
    ],
)

# File groups for toolchain dependencies
filegroup(
    name = "qnx_x86_64_all_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@" + QNX_SDP_NAME + "//:x86_64_all_files",
    ],
)

filegroup(
    name = "qnx_x86_64_compiler_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@" + QNX_SDP_NAME + "//:x86_64_compiler_files",
    ],
)

filegroup(
    name = "qnx_x86_64_linker_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@" + QNX_SDP_NAME + "//:x86_64_linker_files",
    ],
)

filegroup(
    name = "qnx_aarch64_all_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@" + QNX_SDP_NAME + "//:aarch64_all_files",
    ],
)

filegroup(
    name = "qnx_aarch64_compiler_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@" + QNX_SDP_NAME + "//:aarch64_compiler_files",
    ],
)

filegroup(
    name = "qnx_aarch64_linker_files",
    srcs = [
        "//qnx_sdp/wrappers:qcc_wrapper",
        "@" + QNX_SDP_NAME + "//:aarch64_linker_files",
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

# CC Toolchain for aarch64
cc_toolchain(
    name = "cc_toolchain_qnx_aarch64",
    all_files = ":qnx_aarch64_all_files",
    compiler_files = ":qnx_aarch64_compiler_files",
    dwp_files = ":qnx_aarch64_all_files",
    linker_files = ":qnx_aarch64_linker_files",
    objcopy_files = ":qnx_aarch64_all_files",
    strip_files = ":qnx_aarch64_all_files",
    supports_param_files = 0,
    supports_header_parsing = False,
    toolchain_config = ":qnx_aarch64_toolchain_config",
    toolchain_identifier = "qnx-aarch64",
)

# Toolchain Suite
cc_toolchain_suite(
    name = "qnx_toolchain_suite",
    toolchains = {
        "x86_64": ":cc_toolchain_qnx_x86_64",
        "aarch64": ":cc_toolchain_qnx_aarch64",
    },
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

toolchain(
    name = "toolchain_qnx_aarch64",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:qnx",
        "@platforms//cpu:aarch64",
    ],
    toolchain = ":cc_toolchain_qnx_aarch64",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)
