"""QNX Toolchain Configuration for Bazel"""

load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "env_entry",
    "env_set",
    "feature",
    "flag_group",
    "flag_set",
    "tool_path"
)
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

    all_cpp_compile_actions = [
        ACTION_NAMES.clif_match,
        ACTION_NAMES.cpp_compile,
        ACTION_NAMES.cpp_header_parsing,
        ACTION_NAMES.cpp_module_compile,
        ACTION_NAMES.cpp_module_codegen,
        ACTION_NAMES.linkstamp_compile,
    ]

    all_compile_actions = all_cpp_compile_actions + [
        ACTION_NAMES.assemble,
        ACTION_NAMES.c_compile,
        ACTION_NAMES.preprocess_assemble,
    ]

    all_link_actions = [
        ACTION_NAMES.cpp_link_executable,
        ACTION_NAMES.cpp_link_dynamic_library,
        ACTION_NAMES.cpp_link_nodeps_dynamic_library,
    ]

    all_actions = all_compile_actions + all_link_actions

    # setup environment variables for QNX
    sdp_env_flags_feature = feature(
        name = "sdp_env",
        enabled = True,
        env_sets = [
            env_set(
                actions = all_actions,
                env_entries = [
                    env_entry(
                        key = "QNX_SDP_ENV_SH",
                        value = "${{pwd}}/external/qnx_sdp/qnxsdp-env.sh",
                    ),
                    env_entry(
                        key = "QNX_BIN_DIR",
                        value = "$(location @qnx_sdp//:bin_dir)",
                    ),
                    env_entry(
                        key = "QNX_SDP_WRAP",
                        value = "$(location @qnx_sdp//:qcc_wrapper)",
                    ),
                ],
            ),
        ],
    )

    # Unfiltered compiler flags (these come first, before Bazel's flags)
    unfiltered_compile_flags_feature = feature(
        name = "unfiltered_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-V",
                            "gcc_ntox86_64",
                            "-std=gnu++14",
                            "-fdiagnostics-color=always",
                            "-frecord-gcc-switches",
                        ],
                    ),
                ],
            ),
        ],
    )

    # Compiler flags
    compiler_flags_feature = feature(
        name = "compiler_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-V",
                            "gcc_ntox86_64",
                            "-std=gnu++14",
                            "-fdiagnostics-color=always",
                            "-frecord-gcc-switches",
                        ],
                    ),
                ],
            ),
        ],
    )

    # paths
    include_paths_flags_feature = feature(
        name = "include_paths_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-I%{include_paths}"],
                        iterate_over = "include_paths",
                    ),
                ],
            ),
        ],
    )

    # Linker flags
    linker_flags_feature = feature(
        name = "linker_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-V",
                            "gcc_ntox86_64",
                            "-lc++",
                        ],
                    ),
                ],
            ),
        ],
    )

    features = [
        compiler_flags_feature,
        include_paths_flags_feature,
        linker_flags_feature,
        sdp_env_flags_feature,
        unfiltered_compile_flags_feature,
    ]

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
        features = features,
        tool_paths = tool_paths,
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
