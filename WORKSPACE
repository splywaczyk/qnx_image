workspace(name = "qnx")

load("//third_party:dependencies.bzl", "third_party_dependencies")
third_party_dependencies()

# Register QNX toolchains
register_toolchains(
    "//bazel:toolchain_qnx_x86_64",
    "//bazel:toolchain_qnx_aarch64",
)
