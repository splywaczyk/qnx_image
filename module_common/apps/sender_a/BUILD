"""Message Sender A - C++17 (Authorized Sender)"""

cc_library(
    name = "message",
    hdrs = ["message.h"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "message_sender_lib",
    srcs = ["message_sender.cpp"],
    hdrs = ["message_sender.h"],
    deps = [":message"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "sender_a",
    srcs = ["main.cpp"],
    deps = [":message_sender_lib"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "sender_a_secpol",
    srcs = ["sender_a.secpol"],
    visibility = ["//visibility:public"],
)
