"""QNX SDP Setup"""

load("//qnx_sdp:variables.bzl", "QNX_SDP_NAME", "QNX_SDP_PATH")

def qnx_sdp_setup():  # @unused (name argument not needed for WORKSPACE setup)
    """Setup QNX SDP as a local repository."""
    native.new_local_repository(
        name = QNX_SDP_NAME,
        path = QNX_SDP_PATH,
        build_file = "//qnx_sdp:sdp.BUILD",
    )
