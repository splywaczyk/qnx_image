"""QNX Toolchain Configuration for Bazel"""

load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
     "feature",
     "flag_group",
     "flag_set",
     "tool_path")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")

def _cc_toolchain_config_impl(ctx):
    """Implements cc_toolchain_config for QNX"""

    tool_paths = [
        tool_path(
            name = "gcc",
            path = ctx.attr.compiler_path,
        ),
        tool_path(
            name = "ld",
            path = ctx.attr.linker_path,
        ),
        tool_path(
            name = "ar",
            path = ctx.attr.ar_path,
        ),
        tool_path(
            name = "cpp",
            path = "/bin/false",
        ),
        tool_path(
            name = "gcov",
            path = "/bin/false",
        ),
        tool_path(
            name = "nm",
            path = ctx.attr.nm_path,
        ),
        tool_path(
            name = "objdump",
            path = ctx.attr.objdump_path,
        ),
        tool_path(
            name = "strip",
            path = ctx.attr.strip_path,
        ),
    ]

    # Unfiltered compiler flags (these come first, before Bazel's flags)
    unfiltered_compile_flags = feature(
        name = "unfiltered_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.assemble,
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.linkstamp_compile,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                    ACTION_NAMES.cpp_module_codegen,
                    ACTION_NAMES.lto_backend,
                    ACTION_NAMES.clif_match,
                ],
                flag_groups = [
                    flag_group(
                        flags = ctx.attr.compile_flags,
                    ),
                ],
            ),
        ],
    )

    # Linker flags
    linker_flags = feature(
        name = "linker_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.cpp_link_executable,
                    ACTION_NAMES.cpp_link_dynamic_library,
                    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
                ],
                flag_groups = [
                    flag_group(
                        flags = ctx.attr.link_flags,
                    ),
                ],
            ),
        ],
    )

    features = [unfiltered_compile_flags, linker_flags]

    # Environment variables for QNX
    cxx_builtin_include_directories = ctx.attr.cxx_builtin_include_directories

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = ctx.attr.toolchain_identifier,
        host_system_name = "local",
        target_system_name = ctx.attr.target_system_name,
        target_cpu = ctx.attr.target_cpu,
        target_libc = ctx.attr.target_libc,
        compiler = ctx.attr.compiler,
        abi_version = ctx.attr.abi_version,
        abi_libc_version = ctx.attr.abi_libc_version,
        tool_paths = tool_paths,
        features = features,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
    )

cc_toolchain_config = rule(
    implementation = _cc_toolchain_config_impl,
    attrs = {
        "toolchain_identifier": attr.string(mandatory = True),
        "target_system_name": attr.string(mandatory = True),
        "target_cpu": attr.string(mandatory = True),
        "target_libc": attr.string(mandatory = True),
        "compiler": attr.string(mandatory = True),
        "abi_version": attr.string(mandatory = True),
        "abi_libc_version": attr.string(mandatory = True),
        "compiler_path": attr.string(mandatory = True),
        "linker_path": attr.string(mandatory = True),
        "ar_path": attr.string(mandatory = True),
        "nm_path": attr.string(mandatory = True),
        "objdump_path": attr.string(mandatory = True),
        "strip_path": attr.string(mandatory = True),
        "compile_flags": attr.string_list(default = []),
        "link_flags": attr.string_list(default = []),
        "cxx_builtin_include_directories": attr.string_list(default = []),
    },
    provides = [CcToolchainConfigInfo],
)
