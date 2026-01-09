# Module 3: QNX IPC Communication Training

This module demonstrates QNX message passing IPC with one receiver and two sender applications, progressing from basic IPC to secure IPC with security policies.

## Overview

This module has two parts:

### Part 1: Basic IPC Communication
- **Receiver**: Waits for messages on channel `/tmp/qnx_receiver`
- **Sender A**: Sends 10 messages every 2 seconds with type=1, subtype=100
- **Sender B**: Sends 7 messages every 3 seconds with type=2, subtype=200

### Part 2: Secure IPC with Security Policies (Module 4)
- Same IPC architecture with added security layer
- Security policies control which processes can communicate
- Demonstrates Mandatory Access Control (MAC)
- Shows authorized vs unauthorized access patterns

## Directory Structure

```
03_ipc/
├── BUILD                       # Bazel package with qnx_ifs rules
├── QUICKSTART.md               # Quick start guide
├── README.md                   # This file
├── code/                       # Source code (if present)
├── image_buildfiles/           # QNX IFS build files
│   ├── BUILD                   # Bazel filegroup for build files
│   ├── ipc.build               # Basic IPC system image
│   └── ipc_secure.build        # Secure IPC system image
├── scripts/                    # Scripts
│   └── run_qemu.sh             # QEMU launcher
└── secpol/                     # Security policy compilation
    └── BUILD                   # Compiles modular policy fragments

00_common/                      # Shared application components
├── apps/                       # Reusable C++ applications
│   ├── hello_world/            # Simple hello world app
│   ├── receiver/               # Secure message receiver
│   │   ├── inc/                # Header files
│   │   ├── src/                # Source files
│   │   └── BUILD
│   ├── sender_a/               # Authorized sender
│   │   ├── inc/                # Header files
│   │   ├── src/                # Source files
│   │   └── BUILD
│   └── sender_b/               # Unauthorized sender
│       ├── inc/                # Header files
│       ├── src/                # Source files
│       └── BUILD
├── image_buildfiles/           # Common IFS build components
└── secpol/                     # Security policy definitions
    ├── BUILD                   # Exports all secpol files
    ├── receiver.secpol         # Receiver security policy fragment
    ├── sender_a.secpol         # Sender A security policy fragment
    └── sender_b.secpol         # Sender B security policy fragment
```

## Building and Running

### Prerequisites

- QNX SDP 8.0 environment sourced
- Bazel configured for QNX cross-compilation
- QEMU installed

### Part 1: Basic IPC Communication

#### Build and Run

From the workspace root:

```bash
# Build the IFS image
bazel build //03_ipc:ipc_ifs

# Run in QEMU
bazel run //03_ipc:run_qemu

# The IFS image will be created at:
# bazel-bin/03_ipc/ipc.ifs
```

This will:
1. Build all three applications (receiver, sender_a, sender_b) using Bazel
2. Create the IFS image using mkifs with the proper configuration
3. Include all necessary QNX components and libraries
4. Automatically launch the receiver and both senders
5. Display all message exchanges in the console

#### Expected Output

When running the basic IPC demo, you should see:

1. **Receiver Output**:
   - Initialization message with process ID and channel ID
   - Message received notifications showing type, subtype, and data

2. **Sender A Output**:
   - Connection confirmation
   - 10 messages sent every 2 seconds
   - Message format: "Hello from SENDER1 - Message #X"
   - Type: 1, Subtype: 100

3. **Sender B Output**:
   - Connection confirmation
   - 7 messages sent every 3 seconds
   - Message format: "Greetings from SENDER2 - Message #X"
   - Type: 2, Subtype: 200

#### Message Flow

```
Time 0s:    Receiver starts and waits
Time 2s:    Sender A starts, connects, sends message #1
Time 3s:    Sender B starts, connects, sends message #1
Time 4s:    Sender A sends message #2
Time 6s:    Sender A sends message #3, Sender B sends message #2
Time 8s:    Sender A sends message #4
...
```

### Part 2: Secure IPC with Security Policies

## Security Policy Overview

**Sources:**
- https://www.qnx.com/developers/docs/8.0/com.qnx.doc.neutrino.utilities/topic/p/procnto.html
- https://www.qnx.com/developers/docs/8.0/com.qnx.doc.security.system/topic/manual/using_security_policies.html
- https://www.qnx.com/developers/docs/8.0/com.qnx.doc.security.system/topic/manual/secpol_language.html

This demonstrates QNX security policies and access control mechanisms using IPC as a practical example. You'll learn how to:

- Implement security policies to control IPC access
- Use QNX security framework features
- Handle security policy violations (EACCES/EPERM errors)
- Configure procnto with security enforcement (-S flag)
- Audit security events

### Security Architecture

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

### Security Policy Explained

#### Modular Policy Architecture

The security policy is split into three fragments, each co-located with its application:

1. **`receiver.secpol`** - Defines `receiver_secure_t` type and its permissions
2. **`sender_a.secpol`** - Defines `sender_a_secure_t` type (authorized)
3. **`sender_b.secpol`** - Defines `sender_b_secure_t` type (unauthorized)

These fragments are combined during build by `secpolcompile` to create a single `secpol.bin` binary.

#### Benefits of Modular Approach

- **Separation of Concerns**: Each component owns its security definition
- **Maintainability**: Changes to one component don't affect others
- **Flexibility**: Easy to add/remove components
- **Co-location**: Policy lives with the code it protects
- **Scalability**: Supports large systems with many components

#### Policy Fragments

The modular policy defines three types (processes) and their access rights:

##### Types (Security Labels)

1. **receiver_secure_t** - Receiver process type
   - Defined in: `00_common/secpol/receiver.secpol`
   - Can attach name: `/dev/name/local/qnx_receiver_secure`
   - Ability: `able_create`
   - Purpose: Receives messages from authorized senders

2. **sender_a_secure_t** - Authorized sender type
   - Defined in: `00_common/secpol/sender_a.secpol`
   - Can connect to: `receiver_secure_t:channel`
   - Ability: `able_create`
   - Purpose: Demonstrates successful authorized IPC

3. **sender_b_secure_t** - Unauthorized sender type
   - Defined in: `00_common/secpol/sender_b.secpol`
   - **Cannot** connect to: `receiver_secure_t:channel` (no rule)
   - Ability: `able_create`
   - Purpose: Demonstrates security policy enforcement

##### Key Rules

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

##### Security Model

- **Default Policy**: Deny-All (whitelist approach)
- **Type Enforcement**: Mandatory Access Control (MAC)
- **Process Types**: Assigned at launch with `on -T <type>`
- **Resource Inheritance**: Channels inherit creator's type
- **Policy Activation**: `secpolpush` loads policy at boot

### Building Secure IPC Module

From the workspace root:

```bash
# Build the compiled security policy from modular fragments
bazel build //03_ipc/secpol:ipc_policy_compile

# Build all applications and create secure IFS image
bazel build //03_ipc:ipc_secure_ifs

# The IFS image will be created at:
# bazel-bin/03_ipc/ipc_secure.ifs

# The compiled policy binary:
# bazel-bin/03_ipc/secpol/secpol.bin
```

**Build Process**:
1. Compiles three C++ applications using Bazel (receiver, sender_a, sender_b)
2. Collects security policy fragments from `00_common/secpol/`
3. Runs `secpolcompile` to merge fragments into single `secpol.bin`
4. Creates IFS image with `secpolpush` for security enforcement
5. Launches processes with `on -T <type>` to assign security types
6. Packages all components with proper dependencies

### Running Secure IPC Demo

```bash
# Launch QEMU with secure IFS
bazel run //03_ipc:run_qemu_secure
```

### Expected Output (Secure Mode)

```
=============================================
  QNX Security Policies & Access Control
  Module 3 Secure IPC Training
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
Authorized: sender_a only
Secure channel created (chid: 1)
Security policy active
Waiting for authorized messages...
===========================================

Starting sender_a (AUTHORIZED by policy)...
===========================================
  SENDER A Started
===========================================
Process ID: 5
Connecting to: /tmp/qnx_receiver_secure
Connected successfully (coid: 1073741825)
Sending messages every 2 seconds...
===========================================

[SENDER A] Sending message #1: Hello from SENDER A - Message #1

--- Authorized Message Received ---
From: rcvid 1073741825 (AUTHORIZED by secpol)
Type: 1
Subtype: 100
Data: Hello from SENDER A - Message #1
-----------------------------------

[SENDER A] Reply received: 0

Starting sender_b (UNAUTHORIZED - will be BLOCKED)...
===========================================
  SENDER B Started
===========================================
Process ID: 6
Connecting to: /tmp/qnx_receiver_secure

[SENDER B] Sending message #1: Greetings from SENDER B - Message #1
Error: MsgSend failed: Permission denied

[SECURITY POLICY VIOLATION]
===========================
Unauthorized access blocked by secpol!
errno: 13 (Permission denied)
===========================
```

### Key Observations

1. **sender_a (AUTHORIZED)**
   - ✓ Successfully connects to receiver
   - ✓ Sends and receives messages
   - ✓ Communication works normally

2. **sender_b (UNAUTHORIZED)**
   - ✗ Connection or send fails
   - ✗ Receives EACCES/EPERM error
   - ✗ Security policy blocks access
   - ✓ Error is logged in audit log

3. **receiver_secure**
   - Detects security violations
   - Continues operating normally
   - Only processes authorized messages

## Implementation Details

### Application Architecture

All applications are organized with C++17 features and proper structure:

```
00_common/apps/app_name/
├── inc/                    # Header files
│   ├── *.h                 # Class declarations
│   └── message.h           # Message structures
├── src/                    # Source files
│   ├── main.cpp            # Entry point
│   └── *.cpp               # Implementation
└── BUILD                   # Bazel build configuration
```

### MessageReceiver (receiver.cpp)

**Purpose**: Message receiver with optional security policy awareness

**Key Features**:
- Uses `name_attach()` to create a named channel
- Implements `MsgReceive()` loop to handle incoming messages
- Sends replies using `MsgReply()`
- Handles both regular messages and pulses
- In secure mode: Detects and logs security violations

**Security Error Handling** (Secure Mode):
```cpp
if (errno == EACCES || errno == EPERM) {
    std::cout << "[SECURITY POLICY VIOLATION]\n";
    std::cout << "Unauthorized access blocked by secpol!\n";
}
```

### MessageSender (sender_a.cpp, sender_b.cpp)

**Purpose**: Message senders with optional security types

**Key Features**:
- Uses `name_open()` to connect to the receiver
- Implements retry logic for connection attempts
- Sends messages using `MsgSend()` (synchronous)
- Waits for replies before continuing
- Uses C++17 features: std::optional, std::chrono, RAII

**Behavior Differences**:
- **sender_a**: Authorized (type: sender_a_secure_t) - Communication succeeds
- **sender_b**: Unauthorized (type: sender_b_secure_t) - Communication blocked

## Learning Objectives

### Basic IPC Module
1. Understand QNX message passing IPC
2. Learn how to create named channels
3. Implement client-server communication patterns
4. Handle multiple concurrent senders
5. Work with Bazel build system for QNX
6. Create and deploy QNX IFS images

### Secure IPC Module
1. **QNX Security Architecture** - How QNX enforces security policies
2. **Policy-Based Access Control** - Defining who can access what
3. **Secure IPC** - Protecting message-passing channels
4. **Security Auditing** - Logging security events
5. **Error Handling** - Dealing with permission denied errors
6. **Modular Security Policies** - Scalable policy architecture

## Testing and Verification

### Check Running Processes

```bash
# In QEMU shell
pidin
```

Expected: All three processes running

### View Security Audit Log (Secure Mode)

```bash
cat /tmp/security_audit.log
```

Expected: Entries showing denied operations from sender_b

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
pidin -p sender_a_secure
pidin -p sender_b_secure
```

## Security Concepts

### 1. Mandatory Access Control (MAC)

QNX security policies implement MAC, where:
- Access decisions are based on policy, not user permissions
- Policies are enforced by the kernel (procnto)
- Even root cannot bypass policy restrictions

### 2. Principle of Least Privilege

Each process is granted only the minimum permissions needed:
- sender_a: connect, send, receive_reply
- sender_b: explicitly denied
- receiver: create_channel, receive, reply

### 3. Defense in Depth

Multiple security layers:
- Process isolation (QNX microkernel)
- Security policies (this module)
- Audit logging (track violations)
- Error handling (graceful failure)

### 4. Audit Trail

All security events are logged:
- Allowed operations (optional)
- Denied operations (always)
- Timestamps and process info
- Resource access attempts

## Customization

### Add a Third Sender (Authorized)

With modular policies, adding a new component is straightforward:

1. **Create application directory**:
   ```bash
   mkdir -p 00_common/apps/sender_c
   ```

2. **Create sender_c.cpp** (copy from sender_a)

3. **Create sender_c.secpol** policy fragment:
   ```bash
   cat > 00_common/secpol/sender_c.secpol <<'EOF'
   type sender_c_secure_t;
   allow sender_c_secure_t receiver_secure_t:channel connect;
   allow sender_c_secure_t self:ability { able_create };
   EOF
   ```

4. **Create BUILD file** in app directory

5. **Update 03_ipc/secpol/BUILD** to include new fragment

6. **Update IFS buildfile** to launch with security type:
   ```bash
   on -T sender_c_secure_t /proc/boot/sender_c &
   ```

### Modify Security Rules

To change sender_b from unauthorized to authorized:

Edit `00_common/secpol/sender_b.secpol`:

```
type sender_b_secure_t;

# Add this rule to authorize sender_b
allow sender_b_secure_t receiver_secure_t:channel connect;

allow sender_b_secure_t self:ability {
    able_create
};
```

Then rebuild: `bazel build //03_ipc/secpol:ipc_policy_compile`

## Common Errors and Solutions

### Error: MsgSend failed: Permission denied

**Cause**: Security policy denied the operation

**Solution**: This is expected for sender_b. Check policy file if unexpected.

### Error: Security policy file not found

**Cause**: Policy binary missing from IFS image

**Solution**: Verify policy fragments exist and build succeeds:
```bash
bazel build //03_ipc/secpol:ipc_policy_compile
```

### Error: procnto not started with -S flag

**Cause**: Security enforcement not enabled

**Solution**: Check buildfile has `procnto-smp-instr -S`

### Error: Channel attachment failed

**Cause**: Receiver couldn't create channel

**Solution**: Check receiver has create_channel permission in policy

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

## Troubleshooting

### Build Issues

```bash
# Clean build
bazel clean
bazel build //03_ipc:ipc_ifs
bazel build //03_ipc:ipc_secure_ifs
```

### Runtime Issues

```bash
# Check security status (secure mode)
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

## Exit QEMU

Press `Ctrl+A`, then `X` to exit QEMU

## References

- QNX Neutrino RTOS System Architecture Guide
- QNX Message Passing API documentation
- QNX Security System Guide
- QNX Security Policy Reference
- Bazel documentation for cross-compilation

## Summary

Module 3 demonstrates:

### Basic IPC
- ✓ QNX message passing IPC implementation
- ✓ Named channel creation with `name_attach()`
- ✓ Client-server communication patterns
- ✓ Multiple concurrent senders
- ✓ Synchronous message passing

### Secure IPC
- ✓ QNX security policy implementation with MAC
- ✓ Modular security policy architecture
- ✓ Type-based access control for IPC resources
- ✓ Security policy syntax and rules
- ✓ Handling permission denied errors
- ✓ Security policy compilation with `secpolcompile`
- ✓ Policy enforcement with `secpolpush` and `on -T <type>`
- ✓ Default deny-all security model

**Key Takeaway**: QNX message passing provides efficient IPC, and security policies add kernel-enforced access control that protects critical resources. The modular policy approach enables scalable, maintainable security definitions.

---

**Module 3 - QNX IPC Communication Training**
*Part of QNX Training Series: From Beginner to Advanced*
