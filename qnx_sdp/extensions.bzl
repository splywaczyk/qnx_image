"""Module extensions for QNX SDP setup"""

load("@bazel_tools//tools/build_defs/repo:local.bzl", "new_local_repository")
load("//qnx_sdp:variables.bzl", "QNX_SDP_PATH")

def _qnx_sdp_impl(module_ctx):
    """Implementation of the QNX SDP module extension."""
    new_local_repository(
        name = "qnx_sdp",
        path = QNX_SDP_PATH,
        build_file = "//qnx_sdp:qnx_sdp.BUILD",
    )
    return module_ctx.extension_metadata(
        root_module_direct_deps = ["qnx_sdp"],
        root_module_direct_dev_deps = [],
    )

qnx_sdp_ext = module_extension(
    implementation = _qnx_sdp_impl,
)
