load("//third_party:variables.bzl", "QNX_SDP_PATH", "QNX_SDP_NAME")

#add support for different QNX SDP versions here

def sdp():
    native.new_local_repository(
        name = QNX_SDP_NAME,
        path = QNX_SDP_PATH,
        build_file = "//third_party/qnx/sdp:sdp.BUILD",
    )
