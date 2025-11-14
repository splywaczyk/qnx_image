workspace(name = "qnx")

load("//qnx_sdp:qnx_sdp_setup.bzl", "qnx_sdp_setup")
qnx_sdp_setup()

# Register QNX toolchains
register_toolchains(
    "//bazel/toolchains:toolchain_qnx_x86_64",
)
