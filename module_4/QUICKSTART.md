# Module 4: Quick Start Guide

## What is Module 4?

Module 4 demonstrates **QNX Security Policies and Access Control** through a practical IPC example where:
- **sender1** is AUTHORIZED and can communicate
- **sender2** is DENIED and blocked by security policy
- **receiver_secure** handles both authorized messages and security violations

## Quick Build & Run

From the workspace root:

```bash
# Build everything
bazel build //module_4:ipc_secure_ifs

# Run in QEMU
bazel run //module_4:run_qemu
```

## What You'll See

1. Security policy loaded at boot
2. sender1: Successfully sends messages
3. sender2: Blocked with "Permission denied"
4. receiver: Logs security violations

## Key Files

| File | Purpose |
|------|---------|
| `src/receiver_secure.cpp` | Secure receiver with EACCES/EPERM handling |
| `src/sender1_secure.cpp` | Authorized sender (ALLOWED) |
| `src/sender2_secure.cpp` | Unauthorized sender (DENIED) |
| `secpol/ipc_policy.sp` | Security policy rules |
| `buildfiles/ipc_secure.build` | IFS with procnto -S flag |
| `README.md` | Complete documentation |

## Security Policy Summary

```
Rule 1: ALLOW sender1 → receiver_secure (priority 10)
Rule 2: DENY sender2 → receiver_secure (priority 20)
Rule 3: ALLOW receiver operations (priority 5)
Default: DENY all
```

## Architecture

```
┌─────────────────────┐
│ QNX Security Layer  │
│   (procnto -S)      │
└──────────┬──────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼───┐     ┌───▼───┐
│sender1│     │sender2│
│ ALLOW │     │ DENY  │
└───┬───┘     └───┬───┘
    │             │
    │ ✓           │ ✗
    └──────┬──────┘
           │
     ┌─────▼─────┐
     │ receiver  │
     │  _secure  │
     └───────────┘
```

## Expected Output

```
Starting sender1 (AUTHORIZED by policy)...
[SENDER1] Sending message #1: Hello from SENDER1 - Message #1
--- Authorized Message Received ---
From: rcvid 1073741825 (AUTHORIZED by secpol)
Data: Hello from SENDER1 - Message #1

Starting sender2 (UNAUTHORIZED - will be BLOCKED)...
[SENDER2] Sending message #1: Greetings from SENDER2 - Message #1
Error: MsgSend failed: Permission denied

[SECURITY POLICY VIOLATION]
===========================
Unauthorized access blocked by secpol!
errno: 13 (Permission denied)
===========================
```

## Testing Commands

Inside QEMU:
```bash
pidin                          # View running processes
cat /tmp/security_audit.log    # Check audit log
sloginfo                       # View system logs
```

## Learning Goals

- Understand QNX security policies
- Implement access control for IPC
- Handle permission denied errors
- Configure procnto with security enforcement
- Audit security events

## Next Steps

1. Read the full README.md for detailed explanations
2. Examine the security policy file (secpol/ipc_policy.sp)
3. Study the error handling in receiver_secure.cpp
4. Modify the policy and test changes
5. Proceed to Module 5 for advanced topics

## Troubleshooting

**Build fails**: Check QNX environment is set (`echo $QNX_HOST`)
**Image not found**: Run `bazel build //module_4:ipc_secure_ifs` first
**QEMU won't start**: Ensure qemu-system-x86_64 is installed

For detailed help, see README.md sections:
- Common Errors and Solutions
- Troubleshooting
- Customization

---
Module 4 - QNX Security Policies and Access Control
