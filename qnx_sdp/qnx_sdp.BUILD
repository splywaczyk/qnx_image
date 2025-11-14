
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "qnx_sdp_env_sh",
    srcs = ["qnxsdp-env.sh"],
)

filegroup(
    name = "bin_dir",
    srcs = ["host/linux/x86_64/usr/bin"],
)

# =============================================================================
# x86_64 Architecture Toolchain Binaries
# =============================================================================

filegroup(
    name = "qcc",
    srcs = ["host/linux/x86_64/usr/bin/qcc"],
)

# x86_64 target runtime files
filegroup(
    name = "x86_64_headers",
    srcs = glob([
        "target/qnx/x86_64/usr/include/**",
    ]),
)

filegroup(
    name = "x86_64_libs",
    srcs = glob([
        "target/qnx/x86_64/usr/lib/**",
        "target/qnx/x86_64/lib/**",
    ]),
)

# x86_64 GCC include directories
filegroup(
    name = "x86_64_gcc_includes",
    srcs = glob([
        "host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx8.0.0/*/include/**",
        "host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx8.0.0/*/include-fixed/**",
    ]),
)

# x86_64 GCC runtime libraries
filegroup(
    name = "x86_64_gcc_libs",
    srcs = glob([
        "host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx8.0.0/**/*.a",
        "host/linux/x86_64/usr/lib/gcc/x86_64-pc-nto-qnx8.0.0/**/*.so",
    ]),
)

# Combined x86_64 toolchain files
filegroup(
    name = "x86_64_compiler_files",
    srcs = [
        ":qnx_sdp_env_sh",
        ":x86_64_headers",
        ":x86_64_gcc_includes",
    ],
)

filegroup(
    name = "x86_64_linker_files",
    srcs = [
        ":qnx_sdp_env_sh",
        ":x86_64_libs",
        ":x86_64_gcc_libs",
    ],
)

filegroup(
    name = "x86_64_all_files",
    srcs = [
        ":qnx_sdp_env_sh",
        ":x86_64_headers",
        ":x86_64_libs",
        ":x86_64_gcc_includes",
        ":x86_64_gcc_libs",
    ],
)

# =============================================================================
# Common toolchain files
# =============================================================================

filegroup(
    name = "host_bin",
    srcs = glob([
        "host/linux/x86_64/usr/bin/**",
    ]),
)

filegroup(
    name = "all_files",
    srcs = [
        ":host_bin",
        ":x86_64_all_files",
    ],
)
