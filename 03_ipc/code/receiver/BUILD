"""Secure Message Receiver - C++17"""

cc_library(
    name = "message",
    hdrs = ["inc/message.h"],
    strip_include_prefix = "inc",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "secure_message_receiver_lib",
    srcs = ["src/secure_message_receiver.cpp"],
    hdrs = ["inc/secure_message_receiver.h"],
    strip_include_prefix = "inc",
    deps = [":message"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "receiver",
    srcs = ["src/main.cpp"],
    deps = [":secure_message_receiver_lib"],
    visibility = ["//visibility:public"],
)
