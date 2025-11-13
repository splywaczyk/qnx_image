
package(default_visibility = ["//visibility:public"])

# =============================================================================
# x86_64 Architecture Toolchain Binaries
# =============================================================================

filegroup(
    name = "x86_64_ar",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-ar"],
)

filegroup(
    name = "x86_64_as",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-as"],
)

filegroup(
    name = "x86_64_gcc",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-gcc"],
)

filegroup(
    name = "x86_64_ld",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-ld"],
)

filegroup(
    name = "x86_64_nm",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-nm"],
)

filegroup(
    name = "x86_64_objcopy",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-objcopy"],
)

filegroup(
    name = "x86_64_objdump",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-objdump"],
)

filegroup(
    name = "x86_64_strip",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-strip"],
)

filegroup(
    name = "x86_64_ranlib",
    srcs = ["host/linux/x86_64/usr/bin/ntox86_64-ranlib"],
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
        ":x86_64_gcc",
        ":x86_64_as",
        ":x86_64_headers",
        ":x86_64_gcc_includes",
    ],
)

filegroup(
    name = "x86_64_linker_files",
    srcs = [
        ":x86_64_gcc",
        ":x86_64_ld",
        ":x86_64_ar",
        ":x86_64_libs",
        ":x86_64_gcc_libs",
    ],
)

filegroup(
    name = "x86_64_all_files",
    srcs = [
        ":x86_64_ar",
        ":x86_64_as",
        ":x86_64_gcc",
        ":x86_64_ld",
        ":x86_64_nm",
        ":x86_64_objcopy",
        ":x86_64_objdump",
        ":x86_64_strip",
        ":x86_64_ranlib",
        ":x86_64_headers",
        ":x86_64_libs",
        ":x86_64_gcc_includes",
        ":x86_64_gcc_libs",
    ],
)

# =============================================================================
# aarch64 Architecture Toolchain Binaries
# =============================================================================

filegroup(
    name = "aarch64_ar",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-ar"],
)

filegroup(
    name = "aarch64_as",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-as"],
)

filegroup(
    name = "aarch64_gcc",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-gcc"],
)

filegroup(
    name = "aarch64_ld",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-ld"],
)

filegroup(
    name = "aarch64_nm",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-nm"],
)

filegroup(
    name = "aarch64_objcopy",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-objcopy"],
)

filegroup(
    name = "aarch64_objdump",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-objdump"],
)

filegroup(
    name = "aarch64_strip",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-strip"],
)

filegroup(
    name = "aarch64_ranlib",
    srcs = ["host/linux/x86_64/usr/bin/ntoaarch64-ranlib"],
)

# aarch64 target runtime files
filegroup(
    name = "aarch64_headers",
    srcs = glob([
        "target/qnx/aarch64le/usr/include/**",
    ]),
)

filegroup(
    name = "aarch64_libs",
    srcs = glob([
        "target/qnx/aarch64le/usr/lib/**",
        "target/qnx/aarch64le/lib/**",
    ]),
)

# aarch64 GCC include directories
filegroup(
    name = "aarch64_gcc_includes",
    srcs = glob([
        "host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx8.0.0/*/include/**",
        "host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx8.0.0/*/include-fixed/**",
    ]),
)

# aarch64 GCC runtime libraries
filegroup(
    name = "aarch64_gcc_libs",
    srcs = glob([
        "host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx8.0.0/**/*.a",
        "host/linux/x86_64/usr/lib/gcc/aarch64-unknown-nto-qnx8.0.0/**/*.so",
    ]),
)

# Combined aarch64 toolchain files
filegroup(
    name = "aarch64_compiler_files",
    srcs = [
        ":aarch64_gcc",
        ":aarch64_as",
        ":aarch64_headers",
        ":aarch64_gcc_includes",
    ],
)

filegroup(
    name = "aarch64_linker_files",
    srcs = [
        ":aarch64_gcc",
        ":aarch64_ld",
        ":aarch64_ar",
        ":aarch64_libs",
        ":aarch64_gcc_libs",
    ],
)

filegroup(
    name = "aarch64_all_files",
    srcs = [
        ":aarch64_ar",
        ":aarch64_as",
        ":aarch64_gcc",
        ":aarch64_ld",
        ":aarch64_nm",
        ":aarch64_objcopy",
        ":aarch64_objdump",
        ":aarch64_strip",
        ":aarch64_ranlib",
        ":aarch64_headers",
        ":aarch64_libs",
        ":aarch64_gcc_includes",
        ":aarch64_gcc_libs",
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
        ":aarch64_all_files",
    ],
)
