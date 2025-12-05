ToolInfo = provider(
    doc = "Executable for QNX secpol with needed runfiles",
    fields = ["executable", "files", "env"],
)

def _impl(ctx):
    # Set up QNX environment variables required by secpolcompile
    # These match the environment setup used by the IFS toolchain
    env = {
        "QNX_HOST": "/proc/self/cwd/" + ctx.file.host_dir.path,
        "QNX_TARGET": "/proc/self/cwd/" + ctx.file.target_dir.path,
        "QNX_CONFIGURATION_EXCLUSIVE": "/var/tmp/.qnx",
        "QNX_SHARED_LICENSE_FILE": "/home/qnx/.qnx/license/licenses",
        "PATH": "/proc/self/cwd/" + ctx.file.host_dir.path + "/usr/bin",
    }

    return [
        platform_common.ToolchainInfo(
            tool_info = ToolInfo(
                env = env,
                executable = ctx.executable.executable,
                files = depset(ctx.files.host + ctx.files.target, transitive = [ctx.attr.executable.default_runfiles.files]),
            ),
        ),
    ]

qnx_secpol_toolchain_config = rule(
    _impl,
    attrs = {
        "executable": attr.label(
            cfg = "exec",
            executable = True,
            mandatory = True,
        ),
        "host_dir": attr.label(
            cfg = "exec",
            mandatory = True,
            allow_single_file = True,
        ),
        "target_dir": attr.label(
            cfg = "exec",
            mandatory = True,
            allow_single_file = True,
        ),
        "host": attr.label(
            cfg = "exec",
            mandatory = True,
        ),
        "target": attr.label(
            cfg = "exec",
            mandatory = True,
        ),
    },
)
