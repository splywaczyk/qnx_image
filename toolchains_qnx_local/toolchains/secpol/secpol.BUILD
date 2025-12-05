load("@score_toolchains_qnx//toolchains/secpol:toolchain.bzl", "qnx_secpol_toolchain_config")

qnx_secpol_toolchain_config(
    name = "secpolcompile_qnx_x86_64_toolchain",
    executable = "@%{toolchain_sdp}//:secpolcompile",
    host_dir = "@%{toolchain_sdp}//:host_dir",
    target_dir = "@%{toolchain_sdp}//:target_dir",
    host = "@%{toolchain_sdp}//:host_all",
    target = "@%{toolchain_sdp}//:target_all",
)

toolchain(
    name = "secpolcompile-qnx-x86_64-qnx8",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:qnx",
    ],
    toolchain = ":secpolcompile_qnx_x86_64_toolchain",
    toolchain_type = "@score_toolchains_qnx//toolchains/secpol:toolchain_type",
)
