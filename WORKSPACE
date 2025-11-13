workspace(name = "qnx")

load("//qnx_sdp:setup.bzl", "qnx_sdp_setup")
qnx_sdp_setup()

# Register QNX toolchains
register_toolchains(
    "//bazel/toolchains:toolchain_qnx_x86_64",
    "//bazel/toolchains:toolchain_qnx_aarch64",
)
