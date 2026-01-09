"""Message Sender B - C++17 (Unauthorized Sender - will be blocked)"""

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
    name = "sender_b",
    srcs = ["main.cpp"],
    deps = [":message_sender_lib"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "sender_b_secpol",
    srcs = ["sender_b.secpol"],
    visibility = ["//visibility:public"],
)
