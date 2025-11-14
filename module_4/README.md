# Module 4: QNX Security Policies and Access Control

## Overview

This module demonstrates QNX security policies and access control mechanisms using Inter-Process Communication (IPC) as a practical example. You'll learn how to:

- Implement security policies to control IPC access
- Use QNX security framework features
- Handle security policy violations (EACCES/EPERM errors)
- Configure procnto with security enforcement (-S flag)
- Audit security events

## Learning Objectives

By completing this module, you will understand:

1. **QNX Security Architecture** - How QNX enforces security policies
2. **Policy-Based Access Control** - Defining who can access what
3. **Secure IPC** - Protecting message-passing channels
4. **Security Auditing** - Logging security events
5. **Error Handling** - Dealing with permission denied errors

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   QNX Security Layer                    │
│  (procnto -S enables security policy enforcement)       │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ├── Security Policy: ipc_policy.sp
                  │   ├── ALLOW: sender1 → receiver
                  │   └── DENY:  sender2 → receiver
                  │
       ┌──────────┴──────────┐
       │                     │
   ┌───▼────┐           ┌───▼────┐
   │ sender1│           │ sender2│
   │(ALLOW) │           │(DENY)  │
   └───┬────┘           └───┬────┘
       │                    │
       │  ✓ Authorized      │  ✗ Blocked
       │                    │  (EACCES/EPERM)
       │                    │
       └────────┬───────────┘
                │
         ┌──────▼────────┐
         │   receiver    │
         │   _secure     │
         └───────────────┘
```

## Directory Structure

```
module_4/
├── README.md                  # This file
├── BUILD                      # Bazel package marker
├── src/                       # Source code
│   ├── BUILD                  # Bazel build file
│   ├── receiver_secure.cpp    # Secure message receiver
│   ├── sender1_secure.cpp     # Authorized sender
│   └── sender2_secure.cpp     # Unauthorized sender
├── secpol/                    # Security policies
│   └── ipc_policy.sp          # IPC access control policy
├── buildfiles/                # IFS build files
│   └── ipc_secure.build       # Secure IPC system image
├── images/                    # Generated images (created by build)
├── build_image.sh             # Build script
└── run_qemu.sh                # QEMU launcher
```

## Security Policy Explained

### Policy File: `secpol/ipc_policy.sp`

The security policy defines three subjects (processes) and their access rights:

#### Subjects (Processes)

1. **sender1** - Authorized sender
   - Path: `/proc/boot/sender1_secure`
   - Actions: connect, send, receive_reply
   - Decision: **ALLOW**

2. **sender2** - Unauthorized sender
   - Path: `/proc/boot/sender2_secure`
   - Actions: connect, send
   - Decision: **DENY**

3. **receiver** - Message receiver
   - Path: `/proc/boot/receiver_secure`
   - Actions: create_channel, receive, reply
   - Decision: **ALLOW**

#### Objects (Resources)

- **receiver_channel**
  - Type: channel
  - Name: `/tmp/qnx_receiver_secure`

#### Rules

1. **allow_sender1** (priority 10)
   - Permits sender1 to connect and communicate
   - Audit: yes (log allowed operations)

2. **deny_sender2** (priority 20)
   - Blocks sender2 from connecting
   - Audit: yes (log denied operations)

3. **allow_receiver** (priority 5)
   - Permits receiver to create channel and handle messages
   - Audit: no

#### Default Policy

- **default_action**: DENY
- **default_audit**: yes
- All operations not explicitly allowed are denied

## Application Details

### 1. receiver_secure.cpp

**Purpose**: Secure message receiver with security policy awareness

**Key Features**:
- Attaches to `/tmp/qnx_receiver_secure` channel
- Handles security policy violations gracefully
- Detects EACCES/EPERM errors from blocked senders
- Logs all received messages with authorization status

**Error Handling**:
```cpp
if (errno == EACCES || errno == EPERM) {
    std::cout << "[SECURITY POLICY VIOLATION]\n";
    std::cout << "Unauthorized access blocked by secpol!\n";
}
```

### 2. sender1_secure.cpp

**Purpose**: Authorized sender (allowed by policy)

**Behavior**:
- Connects to `/tmp/qnx_receiver_secure`
- Sends 10 messages at 2-second intervals
- Successfully communicates (policy allows)
- Type: 1, Subtype: 100

### 3. sender2_secure.cpp

**Purpose**: Unauthorized sender (denied by policy)

**Behavior**:
- Attempts to connect to `/tmp/qnx_receiver_secure`
- Connection or send operation fails
- Receives EACCES (Permission denied) error
- Type: 2, Subtype: 200

## Building the Module

### Prerequisites

- QNX SDP 7.1 or 8.0 installed
- Bazel build system configured
- QNX environment variables set
- QEMU for x86_64

### Build Steps

```bash
cd module_4

# Build all applications and create secure image
./build_image.sh
```

**Build Process**:
1. Compiles three C++ applications using Bazel
2. Validates security policy file
3. Creates IFS image with procnto -S flag
4. Includes security policy in boot image

**Output**:
```
Module 4: Security Policies Build
[1/3] Building secure IPC applications...
[2/3] Checking security policy file...
[3/3] Creating secure IPC image...
Build Complete!
Image: images/qnx_secure_ipc.ifs
```

## Running the Demo

### Launch QEMU

```bash
./run_qemu.sh
```

### Expected Output

```
=============================================
  QNX Security Policies & Access Control
  Module 4 Training
=============================================
  Security Framework: ENABLED
  Policy Enforcement: ACTIVE
  procnto flag: -S (security)
=============================================

Loading IPC security policy...
Security policy loaded successfully

Starting secure receiver (authorized domain)...
===========================================
  QNX Secure Message Receiver
===========================================
Process ID: 4
Attaching name: /tmp/qnx_receiver_secure
Security: ENABLED (secpol enforced)
Authorized: sender1 only
Secure channel created (chid: 1)
Security policy active
Waiting for authorized messages...
===========================================

Starting sender1 (AUTHORIZED by policy)...
===========================================
  SENDER1 Started
===========================================
Process ID: 5
Connecting to: /tmp/qnx_receiver_secure
Connected successfully (coid: 1073741825)
Sending messages every 2 seconds...
===========================================

[SENDER1] Sending message #1: Hello from SENDER1 - Message #1

--- Authorized Message Received ---
From: rcvid 1073741825 (AUTHORIZED by secpol)
Type: 1
Subtype: 100
Data: Hello from SENDER1 - Message #1
-----------------------------------

[SENDER1] Reply received: 0

Starting sender2 (UNAUTHORIZED - will be BLOCKED)...
===========================================
  SENDER2 Started
===========================================
Process ID: 6
Connecting to: /tmp/qnx_receiver_secure

[SENDER2] Sending message #1: Greetings from SENDER2 - Message #1
Error: MsgSend failed: Permission denied

[SECURITY POLICY VIOLATION]
===========================
Unauthorized access blocked by secpol!
errno: 13 (Permission denied)
===========================
```

### Key Observations

1. **sender1 (AUTHORIZED)**
   - ✓ Successfully connects to receiver
   - ✓ Sends and receives messages
   - ✓ Communication works normally

2. **sender2 (UNAUTHORIZED)**
   - ✗ Connection or send fails
   - ✗ Receives EACCES/EPERM error
   - ✗ Security policy blocks access
   - ✓ Error is logged in audit log

3. **receiver_secure**
   - Detects security violations
   - Continues operating normally
   - Only processes authorized messages

## Testing and Verification

### Check Running Processes

```bash
# In QEMU shell
pidin
```

Expected: All three processes running

### View Security Audit Log

```bash
cat /tmp/security_audit.log
```

Expected: Entries showing denied operations from sender2

### Monitor System Logs

```bash
sloginfo
```

Expected: Security-related events logged

### Test Process Communication

```bash
# Check receiver channel
pidin -p receiver_secure

# Check sender processes
pidin -p sender1_secure
pidin -p sender2_secure
```

## Security Concepts

### 1. Mandatory Access Control (MAC)

QNX security policies implement MAC, where:
- Access decisions are based on policy, not user permissions
- Policies are enforced by the kernel (procnto)
- Even root cannot bypass policy restrictions

### 2. Principle of Least Privilege

Each process is granted only the minimum permissions needed:
- sender1: connect, send, receive_reply
- sender2: explicitly denied
- receiver: create_channel, receive, reply

### 3. Defense in Depth

Multiple security layers:
- Process isolation (QNX microkernel)
- Security policies (this module)
- Audit logging (track violations)
- Error handling (graceful failure)

### 4. Security Policy Priority

Rules are evaluated by priority (higher number = higher priority):
- Priority 20: deny_sender2 (evaluated first)
- Priority 10: allow_sender1
- Priority 5: allow_receiver

### 5. Audit Trail

All security events are logged:
- Allowed operations (optional)
- Denied operations (always)
- Timestamps and process info
- Resource access attempts

## Common Errors and Solutions

### Error: MsgSend failed: Permission denied

**Cause**: Security policy denied the operation

**Solution**: This is expected for sender2. Check policy file if unexpected.

### Error: Security policy file not found

**Cause**: Policy file missing from IFS image

**Solution**: Verify `ipc_policy.sp` is in secpol/ directory

### Error: procnto not started with -S flag

**Cause**: Security enforcement not enabled

**Solution**: Check buildfile has `procnto-smp-instr -S`

### Error: Channel attachment failed

**Cause**: Receiver couldn't create channel

**Solution**: Check receiver has create_channel permission in policy

## Customization

### Add a Third Sender (Authorized)

1. Create `sender3_secure.cpp` (copy from sender1)
2. Update policy to allow sender3
3. Add to BUILD file
4. Include in IFS buildfile

### Modify Security Rules

Edit `secpol/ipc_policy.sp`:

```
# Example: Allow sender2 with limited permissions
rule allow_sender2_limited {
    subject: sender2
    action: connect
    object: receiver_channel
    decision: ALLOW
    audit: yes
    priority: 15
}
```

### Add Time-Based Restrictions

```
rule allow_sender1_daytime {
    subject: sender1
    action: connect, send
    object: receiver_channel
    decision: ALLOW
    time_range: 08:00-17:00
    priority: 10
}
```

### Add Rate Limiting

```
rule rate_limit_sender1 {
    subject: sender1
    action: send
    object: receiver_channel
    rate_limit: 10/minute
    decision: ALLOW
}
```

## Security Best Practices

1. **Always Enable Security Enforcement**
   - Use `procnto -S` flag
   - Load policies at boot
   - Never run without policies in production

2. **Audit Everything**
   - Log all denied operations
   - Periodically review logs
   - Set up alerts for violations

3. **Principle of Least Privilege**
   - Grant minimum required permissions
   - Use explicit DENY for sensitive resources
   - Regular policy reviews

4. **Test Security Policies**
   - Verify authorized access works
   - Verify unauthorized access is blocked
   - Test edge cases

5. **Defense in Depth**
   - Combine with other security features
   - Use process abilities
   - Implement application-level checks

## Performance Considerations

- **Policy Overhead**: Minimal (checked at kernel level)
- **Audit Logging**: Some overhead (disable for non-critical operations)
- **Priority Order**: Higher priority rules evaluated first (optimize for common cases)

## Further Learning

### Next Steps

1. **Module 5**: Network security policies
2. **Module 6**: File system access control
3. **Module 7**: Secure boot with signed images

### Advanced Topics

- Integrating with LDAP/Active Directory
- Hardware security modules (HSM)
- Trusted Execution Environment (TEE)
- Secure key management

### QNX Documentation

- QNX Security Guide
- Security Policy Reference
- Secure Coding Guidelines
- Adaptive Partitioning with Security

## Troubleshooting

### Build Issues

```bash
# Clean build
bazel clean
./build_image.sh
```

### Runtime Issues

```bash
# Check security status
pidin | grep procnto
# Should show: procnto-smp-instr -S

# Verify policy loaded
ls -l /proc/boot/ipc_policy.sp

# Check logs
sloginfo | grep -i security
```

### Debug Mode

Edit buildfile to add debug output:
```bash
procnto-smp-instr -S -vvv
```

## Summary

Module 4 demonstrates:

- ✓ QNX security policy implementation
- ✓ Access control for IPC resources
- ✓ Security policy syntax and rules
- ✓ Handling permission denied errors
- ✓ Audit logging for security events
- ✓ procnto security enforcement (-S flag)

**Key Takeaway**: QNX security policies provide fine-grained, kernel-enforced access control that protects critical resources even from privileged processes.

---

**Module 4 - QNX Security Policies and Access Control**
*Part of QNX Training Series: From Beginner to Advanced*
