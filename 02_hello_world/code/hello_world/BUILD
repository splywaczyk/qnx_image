"""Module 1: Hello World Application - C++17"""

cc_library(
    name = "qnx_application",
    srcs = ["src/qnx_application.cpp"],
    hdrs = ["inc/qnx_application.h"],
    strip_include_prefix = "inc",
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "hello_world",
    srcs = ["src/main.cpp"],
    deps = [":qnx_application"],
    visibility = ["//visibility:public"],
)
