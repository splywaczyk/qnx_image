"""
This rule generates an Image File System (IFS) for QNX.

In order todo that, the user has to provide a main build file and supporting
files. The main build file will be used as entrypoint and can then include
other build files or perform other operations like packaging any file into the
created IFS.
"""

QNX_FS_TOOLCHAIN = "@score_toolchains_qnx//toolchains/fs/ifs:toolchain_type"

def _qnx_ifs_impl(ctx):
    """ Implementation function of qnx_ifs rule.

        This function will merge all .build files into main .build file and
        produce flashable QNX image.
    """
    inputs = []
    extra_build_files = []

    # Choose output filename
    out_name = ctx.attr.out if ctx.attr.out else "{}.{}".format(ctx.attr.name, ctx.attr.extension)
    if "/" in out_name:
        fail("qnx_ifs.out must be a filename without path components, got: {}".format(out_name))

    out_ifs = ctx.actions.declare_file(out_name)

    ifs_tool_info = ctx.toolchains[QNX_FS_TOOLCHAIN].tool_info

    main_build_file = ctx.file.build_file

    inputs.append(main_build_file)
    inputs.extend(ctx.files.srcs)

    args = ctx.actions.args()

    # Add -r roots BEFORE the build file, resolved relative to the main build file’s dir
    for r in ctx.attr.search_roots:
        # Normalize relative to the main build file’s directory
        root_path = main_build_file.dirname + ("/" + r if not r.startswith("/") else r)
        args.add("-r")
        args.add(root_path)

    args.add_all([
        main_build_file.path,
        out_ifs.path,
    ])

    #Add env variables for bazel labels/targets
    env_to_append = {}
    env_to_append = env_to_append | ifs_tool_info.env

    for key, item in ctx.attr.ext_repo_maping.items():
        env_to_append.update({key: ctx.expand_location(item)})

    ctx.actions.run(
        outputs = [out_ifs],
        inputs = inputs,
        arguments = [args],
        executable = ifs_tool_info.executable,
        env = env_to_append,
        tools = ifs_tool_info.files,
    )

    return [
        DefaultInfo(files = depset([out_ifs])),
    ]

qnx_ifs = rule(
    implementation = _qnx_ifs_impl,
    toolchains = [QNX_FS_TOOLCHAIN],
    attrs = {
        "build_file": attr.label(
            allow_single_file = True,
            doc = "Single label that points to the main build file (entrypoint)",
            mandatory = True,
        ),
        "extension": attr.string(
            default = "ifs",
            doc = "Extension for the generated IFS image. Manipulating this extensions is a workaround for IPNext startup code limitation, when interpreting ifs images. This attribute will either disappear or will be replaced by toolchain configuration in order to keep output files consistent.",
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = "List of labels that are used by the `build_file`",
            allow_empty = True,
        ),
        "ext_repo_maping": attr.string_dict(
            allow_empty = True,
            default = {},
            doc = "We are using dict to map env. variables with of external repository",
        ),
        "out": attr.string(
            default = "",
            doc = "Optional explicit output filename (no path). If empty, uses name + '.' + extension.",
        ),
        "search_roots": attr.string_list(
            default = [],
            doc = "List of paths for mkifs -r, each relative to the main build file's directory (or absolute).",
        ),
    },
)
