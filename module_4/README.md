# Module 4: QNX Security Policies and Access Control

## Sources
  - https://www.qnx.com/developers/docs/8.0/com.qnx.doc.neutrino.utilities/topic/p/procnto.html
  - https://www.qnx.com/developers/docs/8.0/com.qnx.doc.security.system/topic/manual/using_security_policies.html
  - https://www.qnx.com/developers/docs/8.0/com.qnx.doc.security.system/topic/manual/secpol_language.html

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
│           (secpolpush enables enforcement)              │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ├── Modular Security Policy
                  │   ├── receiver.secpol  (defines receiver_secure_t)
                  │   ├── sender_a.secpol  (ALLOW → receiver)
                  │   └── sender_b.secpol  (DENY → receiver)
                  │
       ┌──────────┴──────────┐
       │                     │
   ┌───▼────┐           ┌───▼────┐
   │sender_a│           │sender_b│
   │(ALLOW) │           │(DENY)  │
   └───┬────┘           └───┬────┘
       │                    │
       │  ✓ Authorized      │  ✗ Blocked
       │                    │  (ENOENT)
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
├── QUICKSTART.md              # Quick start guide
├── BUILD                      # Bazel package with qnx_ifs rule
├── secpol/                    # Security policy compilation
│   └── BUILD                  # Compiles modular policy fragments
├── buildfiles/                # IFS build files
│   ├── BUILD                  # Bazel filegroup for build file
│   └── ipc_secure.build       # Secure IPC system image
└── run_qemu.sh                # QEMU launcher script

module_common/apps/            # Shared application components
├── receiver/                  # Secure message receiver
│   ├── BUILD                  # Build for receiver + policy fragment
│   ├── receiver.cpp           # Receiver implementation
│   └── receiver.secpol        # Receiver security policy fragment
├── sender_a/                  # Authorized sender
│   ├── BUILD                  # Build for sender_a + policy fragment
│   ├── sender_a.cpp           # Sender A implementation
│   └── sender_a.secpol        # Sender A security policy fragment
└── sender_b/                  # Unauthorized sender
    ├── BUILD                  # Build for sender_b + policy fragment
    ├── sender_b.cpp           # Sender B implementation
    └── sender_b.secpol        # Sender B security policy fragment
```

**Note**: Security policies are now modular - each application component has its own `.secpol` file that defines only its security type and permissions. These fragments are combined at build time by `secpolcompile`.

## Security Policy Explained

### Modular Policy Architecture

The security policy is now split into three fragments, each co-located with its application:

1. **`receiver.secpol`** - Defines `receiver_secure_t` type and its permissions
2. **`sender_a.secpol`** - Defines `sender_a_secure_t` type (authorized)
3. **`sender_b.secpol`** - Defines `sender_b_secure_t` type (unauthorized)

These fragments are combined during build by `secpolcompile` to create a single `secpol.bin` binary.

### Benefits of Modular Approach

- **Separation of Concerns**: Each component owns its security definition
- **Maintainability**: Changes to one component don't affect others
- **Flexibility**: Easy to add/remove components
- **Co-location**: Policy lives with the code it protects

### Policy Fragments

The modular policy defines three types (processes) and their access rights:

#### Types (Security Labels)

1. **receiver_secure_t** - Receiver process type
   - Defined in: `module_common/apps/receiver/receiver.secpol`
   - Can attach name: `/dev/name/local/qnx_receiver_secure`
   - Ability: `able_create`
   - Purpose: Receives messages from authorized senders

2. **sender_a_secure_t** - Authorized sender type
   - Defined in: `module_common/apps/sender_a/sender_a.secpol`
   - Can connect to: `receiver_secure_t:channel`
   - Ability: `able_create`
   - Purpose: Demonstrates successful authorized IPC

3. **sender_b_secure_t** - Unauthorized sender type
   - Defined in: `module_common/apps/sender_b/sender_b.secpol`
   - **Cannot** connect to: `receiver_secure_t:channel` (no rule)
   - Ability: `able_create`
   - Purpose: Demonstrates security policy enforcement

#### Key Rules

1. **Name Attachment**
   ```
   allow_attach receiver_secure_t /dev/name/local/qnx_receiver_secure;
   ```
   - Receiver can register its IPC channel name

2. **Channel Connection (AUTHORIZED)**
   ```
   allow sender_a_secure_t receiver_secure_t:channel connect;
   ```
   - sender_a can connect to receiver's channel

3. **Implicit Deny (UNAUTHORIZED)**
   - No rule for `sender_b_secure_t → receiver_secure_t:channel connect`
   - Therefore sender_b is **denied by default**

#### Security Model

- **Default Policy**: Deny-All (whitelist approach)
- **Type Enforcement**: Mandatory Access Control (MAC)
- **Process Types**: Assigned at launch with `on -T <type>`
- **Resource Inheritance**: Channels inherit creator's type
- **Policy Activation**: `secpolpush` loads policy at boot

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

- QNX SDP 8.0 installed
- Bazel build system configured with S-CORE toolchains
- QNX environment variables set (QNX_HOST, QNX_TARGET, QNX_CONFIGURATION)
- QEMU for x86_64

### Build Steps

From the workspace root:

```bash
# Build the compiled security policy from modular fragments
bazel build //module_4/secpol:ipc_policy_compile

# Build all applications and create secure IFS image
bazel build //module_4:ipc_secure_ifs

# The IFS image will be created at:
# bazel-bin/module_4/ipc_secure.ifs

# The compiled policy binary:
# bazel-bin/module_4/secpol/secpol.bin
```

**Build Process**:
1. Compiles three C++ applications using Bazel (receiver, sender_a, sender_b)
2. Collects security policy fragments from each application directory
3. Runs `secpolcompile` to merge fragments into single `secpol.bin`
4. Creates IFS image with `secpolpush` for security enforcement
5. Launches processes with `on -T <type>` to assign security types
6. Packages all components with proper dependencies

**Key Build Features**:
- Modular policy fragments enable independent component development
- `secpolcompile` validates syntax and type references during build
- QNX toolchain provides proper environment variables (QNX_HOST, QNX_TARGET)
- Sandboxed build with license and SDK directory access

## Running the Demo

### Launch QEMU

```bash
bazel run //module_4:run_qemu
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

**Cause**: Policy binary missing from IFS image

**Solution**: Verify policy fragments exist and build succeeds:
```bash
bazel build //module_4/secpol:ipc_policy_compile
```

### Error: procnto not started with -S flag

**Cause**: Security enforcement not enabled

**Solution**: Check buildfile has `procnto-smp-instr -S`

### Error: Channel attachment failed

**Cause**: Receiver couldn't create channel

**Solution**: Check receiver has create_channel permission in policy

## Customization

### Add a Third Sender (Authorized)

With modular policies, adding a new component is straightforward:

1. **Create application directory**:
   ```bash
   mkdir -p module_common/apps/sender_c
   ```

2. **Create sender_c.cpp** (copy from sender_a):
   ```bash
   cp module_common/apps/sender_a/sender_a.cpp module_common/apps/sender_c/sender_c.cpp
   # Edit to change name
   ```

3. **Create sender_c.secpol** policy fragment:
   ```bash
   cat > module_common/apps/sender_c/sender_c.secpol <<'EOF'
   type sender_c_secure_t;
   allow sender_c_secure_t receiver_secure_t:channel connect;
   allow sender_c_secure_t self:ability { able_create };
   EOF
   ```

4. **Create BUILD file**:
   ```python
   cc_binary(
       name = "sender_c",
       srcs = ["sender_c.cpp"],
       visibility = ["//visibility:public"],
   )

   filegroup(
       name = "sender_c_secpol",
       srcs = ["sender_c.secpol"],
       visibility = ["//visibility:public"],
   )
   ```

5. **Update module_4/secpol/BUILD** to include new fragment:
   ```python
   filegroup(
       name = "secpol_files",
       srcs = [
           "//module_common/apps/receiver:receiver_secpol",
           "//module_common/apps/sender_a:sender_a_secpol",
           "//module_common/apps/sender_b:sender_b_secpol",
           "//module_common/apps/sender_c:sender_c_secpol",  # Add this
       ],
   )
   ```

6. **Update IFS buildfile** to launch with security type:
   ```bash
   on -T sender_c_secure_t /proc/boot/sender_c &
   ```

### Modify Security Rules for Existing Component

To change sender_b from unauthorized to authorized:

Edit `module_common/apps/sender_b/sender_b.secpol`:

```
type sender_b_secure_t;

# Add this rule to authorize sender_b
allow sender_b_secure_t receiver_secure_t:channel connect;

allow sender_b_secure_t self:ability {
    able_create
};
```

Then rebuild: `bazel build //module_4/secpol:ipc_policy_compile`

### Remove a Component

To remove sender_b:

1. Remove from `module_4/secpol/BUILD` srcs list
2. Remove from IFS buildfile startup script
3. Rebuild

The policy fragment `sender_b.secpol` can stay in place (unused) or be deleted.

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
bazel build //module_4:ipc_secure_ifs
```

### Runtime Issues

```bash
# Check security status
pidin | grep procnto
# Should show: procnto-smp-instr -S

# Verify policy binary loaded
ls -l /proc/boot/secpol.bin

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

- ✓ QNX security policy implementation with Mandatory Access Control (MAC)
- ✓ Modular security policy architecture (per-component fragments)
- ✓ Type-based access control for IPC resources
- ✓ Security policy syntax and rules (QNX policy language)
- ✓ Handling permission denied errors (ENOENT for unauthorized access)
- ✓ Security policy compilation with `secpolcompile`
- ✓ Policy enforcement with `secpolpush` and `on -T <type>`
- ✓ Default deny-all security model (whitelist approach)

**Key Takeaway**: QNX security policies provide fine-grained, kernel-enforced access control that protects critical resources even from privileged processes. The modular policy approach enables scalable, maintainable security definitions that co-locate with application code.

**Modular Security Benefits**:
- Each component owns its security definition
- Easy to add/remove/modify components
- Better separation of concerns
- Policies co-located with the code they protect
- Scalable to large systems with many components

---

**Module 4 - QNX Security Policies and Access Control**
*Part of QNX Training Series: From Beginner to Advanced*
