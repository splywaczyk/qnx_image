"""Secure Message Receiver - C++17"""

cc_library(
    name = "message",
    hdrs = ["message.h"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "secure_message_receiver_lib",
    srcs = ["secure_message_receiver.cpp"],
    hdrs = ["secure_message_receiver.h"],
    deps = [":message"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "receiver",
    srcs = ["main.cpp"],
    deps = [":secure_message_receiver_lib"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "receiver_secpol",
    srcs = ["receiver.secpol"],
    visibility = ["//visibility:public"],
)
