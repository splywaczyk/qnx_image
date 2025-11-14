# module_4/secpol/ipc_policy.sp
# QNX Security Policy for IPC Access Control
#
# This policy demonstrates:
# - ALLOW sender1 to connect to receiver_secure
# - DENY sender2 from connecting to receiver_secure
#
# Policy Syntax:
# ALLOW <subject> <action> <object>
# DENY <subject> <action> <object>

# Security Policy Version
policy_version: 1.0

# Define subjects (processes)
subject sender1 {
    path: /proc/boot/sender1_secure
    uid: 0
    gid: 0
}

subject sender2 {
    path: /proc/boot/sender2_secure
    uid: 0
    gid: 0
}

subject receiver {
    path: /proc/boot/receiver_secure
    uid: 0
    gid: 0
}

# Define objects (resources)
object receiver_channel {
    type: channel
    name: /tmp/qnx_receiver_secure
}

# Security Rules

# Rule 1: ALLOW sender1 to connect and send messages
rule allow_sender1 {
    subject: sender1
    action: connect, send, receive_reply
    object: receiver_channel
    decision: ALLOW
    audit: yes
    priority: 10
}

# Rule 2: DENY sender2 from connecting
rule deny_sender2 {
    subject: sender2
    action: connect, send
    object: receiver_channel
    decision: DENY
    audit: yes
    priority: 20
}

# Rule 3: Allow receiver to create channel and receive messages
rule allow_receiver {
    subject: receiver
    action: create_channel, receive, reply
    object: receiver_channel
    decision: ALLOW
    audit: no
    priority: 5
}

# Default policy: deny all unlisted operations
default_action: DENY
default_audit: yes

# Audit configuration
audit_config {
    log_file: /tmp/security_audit.log
    log_denied: yes
    log_allowed: no
    verbose: yes
}

# Comments:
# - sender1 is AUTHORIZED and will successfully communicate
# - sender2 is DENIED and will receive EACCES/EPERM errors
# - All denied operations are logged for security auditing
# - Priority: higher number = higher priority (processed first)
