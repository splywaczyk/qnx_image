# Pre-compiled security policy binary
# To recompile: export QNX_HOST=/home/qnx/qnx800/host/linux/x86_64 &&
#               export QNX_TARGET=/home/qnx/qnx800/target/qnx &&
#               /home/qnx/qnx800/host/linux/x86_64/usr/bin/secpolcompile -o secpol.bin ipc_policy.sp
filegroup(
    name = "ipc_policy",
    srcs = ["secpol.bin"],
    visibility = ["//module_4:__pkg__"],
)
