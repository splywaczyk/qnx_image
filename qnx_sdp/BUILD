"""QNX SDP Configuration"""

package(default_visibility = ["//visibility:public"])

sh_binary(
    name = "qcc_wrapper",
    srcs = ["wrappers/qcc_wrapper.sh"],
    data = [
        ":license",
        "@qnx_sdp//:qnx_sdp_env_sh",
    ]
)