load("@score_toolchains_qnx//rules/secpolcompile:secpolcompile.bzl", "secpolcompile")

# ==============================================================================
# QNX Security Policy Compilation - Modular Approach
# ==============================================================================
# This BUILD file compiles security policies from modular component fragments.
# Each application component (receiver, sender_a, sender_b) has its own policy
# fragment that defines its security type and permissions.
#
# Benefits of modular approach:
#   - Better separation of concerns (each component owns its policy)
#   - Easier to maintain (changes to one component don't affect others)
#   - More flexible (can add/remove components by changing srcs list)
#   - Co-located with application code (policy lives with the app)
#
# The secpolcompile tool accepts multiple .secpol files and merges them into
# a single binary policy file (secpol.bin) that can be loaded by secpolpush.
# ==============================================================================

filegroup(
    name = "receiver_secpol",
    srcs = ["receiver.secpol"],
)

filegroup(
    name = "sender_a_secpol",
    srcs = ["sender_a.secpol"],
)

filegroup(
    name = "sender_b_secpol",
    srcs = ["sender_b.secpol"],
)

# Collect all security policy fragments from centralized secpol folder
filegroup(
    name = "secpol_files",
    srcs = [
        ":receiver_secpol",
        ":sender_a_secpol",
        ":sender_b_secpol",
    ],
)

# Compile the combined security policy from all fragments
secpolcompile(
    name = "ipc_policy_compile",
    srcs = [":secpol_files"],
    output_name = "secpol.bin",
    visibility = ["//03_ipc:__pkg__"],
)

# Main target that other rules depend on
# Points to the compiled security policy binary
filegroup(
    name = "ipc_policy",
    srcs = [":ipc_policy_compile"],
    visibility = ["//03_ipc:__pkg__"],
)
