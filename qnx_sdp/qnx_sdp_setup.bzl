"""QNX SDP Setup"""
load("@bazel_tools//tools/build_defs/repo:local.bzl", "new_local_repository")
load("//qnx_sdp:variables.bzl", "QNX_SDP_PATH")

def qnx_sdp_setup():  # @unused (name argument not needed for WORKSPACE setup)
    """Setup QNX SDP as a local repository."""
    new_local_repository(
        name = "qnx_sdp",
        path = QNX_SDP_PATH,
        build_file = "//qnx_sdp:qnx_sdp.BUILD",
    )
