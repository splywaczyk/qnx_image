"""Module 1: Hello World Application - C++17"""

cc_library(
    name = "qnx_application",
    srcs = ["qnx_application.cpp"],
    hdrs = ["qnx_application.h"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "hello_world",
    srcs = ["main.cpp"],
    deps = [":qnx_application"],
    visibility = ["//visibility:public"],
)
