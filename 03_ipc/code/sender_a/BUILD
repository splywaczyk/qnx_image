"""Message Sender A - C++17 (Authorized Sender)"""

cc_library(
    name = "message",
    hdrs = ["inc/message.h"],
    strip_include_prefix = "inc",
    visibility = ["//visibility:public"],
)

cc_library(
    name = "message_sender_lib",
    srcs = ["src/message_sender.cpp"],
    hdrs = ["inc/message_sender.h"],
    strip_include_prefix = "inc",
    deps = [":message"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "sender_a",
    srcs = ["src/main.cpp"],
    deps = [":message_sender_lib"],
    visibility = ["//visibility:public"],
)
