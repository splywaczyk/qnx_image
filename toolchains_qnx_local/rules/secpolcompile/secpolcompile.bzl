QNX_SECPOL_TOOLCHAIN = "@score_toolchains_qnx//toolchains/secpol:toolchain_type"

def _impl(ctx):
    """
    Implementation function for secpolcompile
    """
    output = ctx.actions.declare_file(ctx.attr.output_name)

    args = ctx.actions.args()
    args.add("-o")
    args.add(output)
    args.add_all(ctx.files.srcs)

    tool_info = ctx.toolchains[QNX_SECPOL_TOOLCHAIN].tool_info

    # Get environment variables from toolchain (QNX_HOST, QNX_TARGET, etc.)
    env = tool_info.env

    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = [output],
        mnemonic = "SecPolCompile",
        progress_message = "Generating {}...".format(output.basename),
        arguments = [args],
        executable = tool_info.executable,
        env = env,
        tools = tool_info.files,
    )
    return DefaultInfo(files = depset([output]))

secpolcompile = rule(
    implementation = _impl,
    toolchains = [QNX_SECPOL_TOOLCHAIN],
    attrs = {
        "output_name": attr.string(
            mandatory = False,
            default = "secpol.bin",
        ),
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
            doc = "List of raw security policies which will be included in output",
        ),
    },
)
