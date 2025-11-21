# *******************************************************************************
# Copyright (c) 2025 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Apache License Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0
#
# SPDX-License-Identifier: Apache-2.0
# *******************************************************************************
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//toolchains:rules.bzl", "ifs_toolchain", "qcc_toolchain")

def _impl(mctx):
    for mod in mctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'toolchains_qnx' extension")

        for sdp in mod.tags.sdp:
            name = sdp.name
            url = sdp.url
            sha256 = sdp.sha256
            strip_prefix = sdp.strip_prefix

            http_archive(
                name = "%s_sdp" % name,
                urls = [url],
                build_file = "@score_toolchains_qnx//toolchains:sdp.BUILD",
                sha256 = sha256,
                strip_prefix = strip_prefix,
            )

            qcc_toolchain(
                name = "%s_qcc" % name,
                sdp_repo = "%s_sdp" % name,
            )

            ifs_toolchain(
                name = "%s_ifs" % name,
                sdp_repo = "%s_sdp" % name,
            )

toolchains_qnx = module_extension(
    implementation = _impl,
    tag_classes = {
        "sdp": tag_class(
            attrs = {
                "name": attr.string(default = "toolchains_qnx"),
                "url": attr.string(mandatory = True),
                "strip_prefix": attr.string(default = ""),
                "sha256": attr.string(mandatory = True),
            },
        ),
    },
)
