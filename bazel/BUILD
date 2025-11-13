"""QNX Toolchain Build Configuration"""

load(":qnx_toolchain.bzl", "qnx_cc_toolchain_config")
load("//third_party:variables.bzl", "QNX_SDP_PATH")

package(default_visibility = ["//visibility:public"])

# QNX x86_64 Toolchain Configuration
qnx_cc_toolchain_config(
    name = "qnx_x86_64_toolchain_config",
    toolchain_identifier = "qnx-x86_64",
    target_system_name = "qnx",
    target_cpu = "x86_64",
    target_libc = "qnx",
    compiler = "qcc",
    abi_version = "qnx8",
    abi_libc_version = "qnx8",
    compiler_path = "/home/qnx/workspace/qnx/bazel/qcc_wrapper.sh",
    linker_path = "/home/qnx/workspace/qnx/bazel/qcc_wrapper.sh",
    ar_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntox86_64-ar",
    nm_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntox86_64-nm",
    objdump_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntox86_64-objdump",
    strip_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntox86_64-strip",
    compile_flags = [
        "-V", "gcc_ntox86_64",
    ],
    link_flags = [
        "-V", "gcc_ntox86_64",
    ],
    cxx_builtin_include_directories = [
        QNX_SDP_PATH + "/target/qnx/x86_64/usr/include",
        QNX_SDP_PATH + "/host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx8.0.0/12.2.0/include",
    ],
)

# QNX aarch64 Toolchain Configuration
qnx_cc_toolchain_config(
    name = "qnx_aarch64_toolchain_config",
    toolchain_identifier = "qnx-aarch64",
    target_system_name = "qnx",
    target_cpu = "aarch64",
    target_libc = "qnx",
    compiler = "qcc",
    abi_version = "qnx8",
    abi_libc_version = "qnx8",
    compiler_path = "/home/qnx/workspace/qnx/bazel/qcc_wrapper.sh",
    linker_path = "/home/qnx/workspace/qnx/bazel/qcc_wrapper.sh",
    ar_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntoaarch64-ar",
    nm_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntoaarch64-nm",
    objdump_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntoaarch64-objdump",
    strip_path = QNX_SDP_PATH + "/host/linux/x86_64/usr/bin/ntoaarch64-strip",
    compile_flags = [
        "-V", "gcc_ntoaarch64le",
    ],
    link_flags = [
        "-V", "gcc_ntoaarch64le",
    ],
    cxx_builtin_include_directories = [
        QNX_SDP_PATH + "/target/qnx/aarch64le/usr/include",
        QNX_SDP_PATH + "/host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx8.0.0/12.2.0/include",
    ],
)

# File groups for toolchain dependencies
filegroup(
    name = "qnx_all_files",
    srcs = ["qcc_wrapper.sh"],
)

filegroup(
    name = "qnx_compiler_files",
    srcs = ["qcc_wrapper.sh"],
)

filegroup(
    name = "qnx_linker_files",
    srcs = ["qcc_wrapper.sh"],
)

# CC Toolchain for x86_64
cc_toolchain(
    name = "cc_toolchain_qnx_x86_64",
    all_files = ":qnx_all_files",
    compiler_files = ":qnx_compiler_files",
    dwp_files = ":qnx_all_files",
    linker_files = ":qnx_linker_files",
    objcopy_files = ":qnx_all_files",
    strip_files = ":qnx_all_files",
    supports_param_files = 0,
    supports_header_parsing = False,
    toolchain_config = ":qnx_x86_64_toolchain_config",
    toolchain_identifier = "qnx-x86_64",
)

# CC Toolchain for aarch64
cc_toolchain(
    name = "cc_toolchain_qnx_aarch64",
    all_files = ":qnx_all_files",
    compiler_files = ":qnx_compiler_files",
    dwp_files = ":qnx_all_files",
    linker_files = ":qnx_linker_files",
    objcopy_files = ":qnx_all_files",
    strip_files = ":qnx_all_files",
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

# Platform definitions
platform(
    name = "qnx_x86_64",
    constraint_values = [
        "@platforms//os:qnx",
        "@platforms//cpu:x86_64",
    ],
)

platform(
    name = "qnx_aarch64",
    constraint_values = [
        "@platforms//os:qnx",
        "@platforms//cpu:aarch64",
    ],
)
