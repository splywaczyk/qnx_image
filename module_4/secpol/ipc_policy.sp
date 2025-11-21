# ==============================================================================
# QNX Security Policy: IPC Access Control Demonstration
# ==============================================================================
# Policy File: ipc_policy.sp
# Module: 4 - Security Policies and Access Control
# Purpose: Demonstrate mandatory access control (MAC) for IPC channels
#
# This policy controls which processes can connect to IPC message channels.
# It implements a type-based security model where:
#   - receiver_secure_t: Type for the IPC message receiver
#   - sender1_secure_t: Type for authorized sender (ALLOWED)
#   - sender2_secure_t: Type for unauthorized sender (DENIED)
#
# Policy Model: Default Deny-All
#   - Any operation not explicitly allowed is automatically denied
#   - This is the most secure approach (whitelist vs blacklist)
#   - Processes must have explicit permission for each action
#
# Compilation:
#   secpolcompile -o secpol.bin ipc_policy.sp
#
# Installation:
#   Place secpol.bin at /proc/boot/ in IFS image
#
# Activation:
#   secpolpush (in startup script, before starting secured processes)
#
# QNX Security Policy Language Reference:
#   https://www.qnx.com/developers/docs/8.0/com.qnx.doc.security.system/
# ==============================================================================

# ------------------------------------------------------------------------------
# TYPE DEFINITIONS
# ------------------------------------------------------------------------------
# Types are labels assigned to processes and resources.
# They form the basis of access control rules.
#
# Syntax: type <type_name>;
# Convention: Type names end with "_t" suffix
# Scope: Global within this policy

type receiver_secure_t;
# Type: receiver_secure_t
# Purpose: Security type for the IPC message receiver process
# Assigned to: receiver_secure application (via: on -T receiver_secure_t)
# Resources owned:
#   - IPC channel registered at /dev/name/local/qnx_receiver_secure
#   - Channel inherits this type from creator process
# Permissions:
#   - Can attach (register) channel name
#   - Receives connections only from authorized types

type sender1_secure_t;
# Type: sender1_secure_t
# Purpose: Security type for authorized IPC sender
# Assigned to: sender1_secure application (via: on -T sender1_secure_t)
# Resources accessed:
#   - Connects to receiver_secure_t's IPC channel
# Permissions:
#   - Explicitly allowed to connect (see allow rule below)
# Expected behavior: Successfully connects and sends messages

type sender2_secure_t;
# Type: sender2_secure_t
# Purpose: Security type for UNAUTHORIZED IPC sender (demonstration)
# Assigned to: sender2_secure application (via: on -T sender2_secure_t)
# Resources attempted:
#   - Attempts to connect to receiver_secure_t's IPC channel
# Permissions:
#   - NO explicit allow rule (implicitly denied)
# Expected behavior: Connection fails, demonstrates policy enforcement

# ------------------------------------------------------------------------------
# NAME ATTACHMENT RULES
# ------------------------------------------------------------------------------
# Control which process types can register (attach) names in the namespace.
# In QNX, name_attach() registers a name that clients can connect to.
#
# Syntax: allow_attach <type> <absolute_path>;
# Effect: Processes of <type> can call name_attach() for <absolute_path>
# Namespace: /dev/name/local/ = local node, /dev/name/global/ = network-wide

allow_attach receiver_secure_t /dev/name/local/qnx_receiver_secure;
# Rule: Allow name attachment for receiver
# Who: receiver_secure_t processes
# What: Can register name "/dev/name/local/qnx_receiver_secure"
# API: name_attach(NULL, "qnx_receiver_secure", 0)
# Effect:
#   - Receiver process can successfully attach this name
#   - Name becomes visible in /dev/name/local/ directory
#   - Clients can find it with name_open("qnx_receiver_secure", 0)
# Without this rule:
#   - name_attach() would fail with EACCES (Permission denied)
#   - Receiver could not create its IPC channel
# Path requirements:
#   - Must be absolute path starting with /
#   - /dev/name/local/ is for local (single-node) names
#   - /dev/name/global/ would be for network-wide names

# ------------------------------------------------------------------------------
# CHANNEL CONNECTION RULES
# ------------------------------------------------------------------------------
# Control which process types can connect to IPC channels owned by other types.
# In QNX IPC, channels are communication endpoints owned by processes.
#
# Syntax: allow <client_type> <server_type>:channel connect;
# Effect: Processes of <client_type> can connect to channels owned by <server_type>
# API: name_open(<name>, 0) - open connection to named channel

allow sender1_secure_t receiver_secure_t:channel connect;
# Rule: Allow sender1 to connect to receiver's channel
# Who: sender1_secure_t processes (authorized sender)
# What: Connect to IPC channels owned by receiver_secure_t processes
# Access class: :channel (IPC message channel)
# Operation: connect (establish connection, get connection ID)
# API sequence:
#   1. sender1: coid = name_open("qnx_receiver_secure", 0)
#   2. Kernel: Check policy - sender1_secure_t → receiver_secure_t:channel connect
#   3. Policy: ALLOW (rule exists)
#   4. Kernel: Returns valid connection ID (coid)
#   5. sender1: MsgSend(coid, ...) - successfully sends messages
# Effect:
#   - name_open() succeeds, returns valid connection ID
#   - sender1 can send messages via MsgSend()
#   - sender1 can receive replies via MsgReply()
# Without this rule:
#   - name_open() would fail with ENOENT (No such process)
#   - Or EACCES (Permission denied) depending on implementation
#   - Connection would be refused by security policy
# Demonstrates: Authorized access - explicit whitelist entry

# ------------------------------------------------------------------------------
# IMPLICIT DENY FOR SENDER2
# ------------------------------------------------------------------------------
# sender2_secure_t has NO connection rule, therefore it is DENIED.
# This demonstrates the default deny-all security model.
#
# What sender2 attempts:
#   coid = name_open("qnx_receiver_secure", 0);
#
# Policy check:
#   1. sender2 has type: sender2_secure_t
#   2. Receiver channel has type: receiver_secure_t
#   3. Operation: connect to channel
#   4. Policy lookup: sender2_secure_t → receiver_secure_t:channel connect
#   5. No matching rule found
#   6. Default policy: DENY
#   7. name_open() fails
#
# Error returned: ENOENT (2) "No such process"
#   - From sender2's perspective, channel doesn't exist
#   - This is by design - security through obscurity
#   - Prevents information leakage about denied resources
#
# Demonstrates: Unauthorized access blocked by policy

# ------------------------------------------------------------------------------
# ABILITY GRANTS
# ------------------------------------------------------------------------------
# Abilities are process capabilities beyond type-based access control.
# They control low-level kernel operations.
#
# Syntax: allow <type> self:ability { <ability>:<range>; ... };
# Common abilities:
#   - able_create: Create new abilities dynamically
#   - mem_phys: Access physical memory
#   - setuid: Change user ID
#   - io: I/O port access
#   - channel_connect: Connect to channels (type-based)
#
# Note: Most abilities require ranges (e.g., mem_phys:0x1000-0x2000)
#       able_create is an exception - no range needed

allow receiver_secure_t self:ability {
    able_create
};
# Grant: Dynamic ability creation for receiver
# Who: receiver_secure_t processes
# What: able_create ability (create new abilities at runtime)
# Target: self (process itself)
# Purpose:
#   - Allows process to request additional capabilities at runtime
#   - Required for some QNX system calls
#   - Generally safe for application processes
# No range: able_create doesn't use sub-ranges
# Alternative: Could grant specific abilities statically
# Security note: Without this, process has minimal capabilities

allow sender1_secure_t self:ability {
    able_create
};
# Grant: Dynamic ability creation for sender1
# Same as receiver - allows runtime capability management

allow sender2_secure_t self:ability {
    able_create
};
# Grant: Dynamic ability creation for sender2
# Note: sender2 HAS this ability but LACKS channel connection permission
# Demonstrates: Abilities and access rules are independent
# Purpose: Proves denial is due to missing connection rule, not abilities

# ==============================================================================
# POLICY ARCHITECTURE AND SEMANTICS
# ==============================================================================
#
# Security Model: Mandatory Access Control (MAC)
#   - Kernel enforces all security decisions
#   - Applications cannot override policy
#   - Type assignments are permanent (cannot be changed)
#   - All operations are checked against policy
#
# Default Policy: Deny-All (Whitelist)
#   - Any operation not explicitly allowed is denied
#   - More secure than blacklist (deny specific items)
#   - Requires careful policy design to allow needed operations
#   - Prevents unknown/forgotten operations
#
# Type System:
#   - Types are labels, not privileges
#   - Types assigned at process creation (on -T <type>)
#   - Child processes inherit parent's type
#   - Resources (channels, files) inherit creator's type
#   - Types cannot be changed after creation
#
# Rule Structure:
#   - Subject: Who is performing the action (source type)
#   - Object: What is being accessed (target type + resource class)
#   - Operation: What action is requested (connect, read, write, etc.)
#   - Decision: Allow or Deny (only Allow rules are written)
#
# Inheritance:
#   - Process → Child process: Type inherited
#   - Process → IPC channel: Type inherited
#   - Process → Open file: Type inherited
#
# Evaluation Order:
#   1. Extract subject type (requesting process)
#   2. Extract object type (resource owner)
#   3. Determine operation (connect, open, read, etc.)
#   4. Search policy for matching allow rule
#   5. If found → ALLOW
#   6. If not found → DENY (default)
#
# Example Flow (sender1):
#   1. sender1 process has type: sender1_secure_t
#   2. name_open("qnx_receiver_secure") called
#   3. Kernel looks up name, finds channel owned by receiver_secure_t
#   4. Operation: connect to channel
#   5. Policy check: sender1_secure_t → receiver_secure_t:channel connect
#   6. Rule found: allow sender1_secure_t receiver_secure_t:channel connect;
#   7. Decision: ALLOW
#   8. name_open() succeeds, returns connection ID
#
# Example Flow (sender2):
#   1. sender2 process has type: sender2_secure_t
#   2. name_open("qnx_receiver_secure") called
#   3. Kernel looks up name, finds channel owned by receiver_secure_t
#   4. Operation: connect to channel
#   5. Policy check: sender2_secure_t → receiver_secure_t:channel connect
#   6. Rule NOT found (no matching allow rule)
#   7. Decision: DENY (default policy)
#   8. name_open() fails with ENOENT
#
# ==============================================================================
# POLICY COMPILATION AND DEPLOYMENT
# ==============================================================================
#
# Compilation Process:
#   1. Write policy in .sp file (human-readable text)
#   2. Run secpolcompile:
#      $ secpolcompile -o secpol.bin ipc_policy.sp
#   3. Compiler validates:
#      - Syntax correctness
#      - Type references (all types defined)
#      - Rule structure (valid operations and classes)
#      - Path formats (absolute paths for allow_attach)
#   4. Compiler output: secpol.bin (binary format)
#   5. Errors: Compiler reports line numbers and error descriptions
#
# Binary Format:
#   - Proprietary QNX format (not human-readable)
#   - Optimized for kernel parsing
#   - Contains type table, rule table, lookup indexes
#   - Size: Typically < 10 KB for typical policies
#
# Deployment:
#   1. Include secpol.bin in IFS at /proc/boot/secpol.bin
#   2. In startup script: Call secpolpush
#   3. secpolpush loads and activates policy
#   4. Launch processes with types: on -T <type> <program>
#
# Location:
#   - Default: /proc/boot/secpol.bin
#   - Can be changed with secpolpush -f <path>
#   - Must be accessible before secpolpush runs
#
# Activation:
#   - secpolpush must run before type-assigned processes start
#   - Can only be called once per boot
#   - Irreversible - cannot disable after enabled
#   - All subsequent processes subject to policy
#
# ==============================================================================
# TROUBLESHOOTING GUIDE
# ==============================================================================
#
# Compilation Errors:
#
#   Error: "non-absolute path 'qnx_receiver_secure'"
#   Cause: allow_attach requires absolute path
#   Fix: Use /dev/name/local/qnx_receiver_secure
#
#   Error: "undefined type 'sender1_secure_t'"
#   Cause: Type not defined before use
#   Fix: Add: type sender1_secure_t; before allow rule
#
#   Error: "ability 'able_create' does not support sub-ranges"
#   Cause: Trying to use range with able_create
#   Fix: Use: able_create (not able_create:all)
#
#   Error: "undefined ability channel_create"
#   Cause: Ability doesn't exist in QNX
#   Fix: Use correct ability names (able_create, mem_phys, etc.)
#
# Runtime Issues:
#
#   Problem: sender2 connects when it should be denied
#   Debug:
#     1. Check secpolpush was called: pidin | grep secpolpush
#     2. Verify policy loaded: ls -l /proc/boot/secpol.bin
#     3. Check types assigned: pidin -f t
#     4. Verify rule not present for sender2
#
#   Problem: sender1 also denied
#   Debug:
#     1. Check policy compilation: Re-run secpolcompile
#     2. Verify type names match: Policy vs on -T command
#     3. Check rule syntax: allow sender1_secure_t receiver_secure_t:channel connect;
#     4. Check policy loaded: secpolpush should not error
#
#   Problem: Receiver can't attach name
#   Debug:
#     1. Check allow_attach rule exists
#     2. Verify path matches: Policy vs name_attach() call
#     3. Ensure path is absolute: /dev/name/local/...
#     4. Check receiver has correct type: on -T receiver_secure_t
#
# ==============================================================================
# EXTENDING THIS POLICY
# ==============================================================================
#
# Adding a new authorized sender:
#   1. Define type: type sender3_secure_t;
#   2. Add connection rule: allow sender3_secure_t receiver_secure_t:channel connect;
#   3. Add ability: allow sender3_secure_t self:ability { able_create };
#   4. Recompile: secpolcompile -o secpol.bin ipc_policy.sp
#   5. Rebuild IFS with new secpol.bin
#   6. Launch with type: on -T sender3_secure_t /proc/boot/sender3
#
# Adding file access control:
#   1. Define file type: type logfile_t;
#   2. Allow write access: allow app_t logfile_t:file write;
#   3. Label file at creation: Files inherit creator's type
#   4. Control access via policy rules
#
# Adding network access control:
#   1. Define types for network servers/clients
#   2. Use :socket class for socket operations
#   3. Control bind, connect, accept operations
#   4. Example: allow client_t server_t:socket connect;
#
# Adding multi-level security (MLS):
#   1. Define types for each security level
#   2. Create hierarchical rules (low→high read, high→low write)
#   3. Enforce information flow policies
#
# Best Practices:
#   - Define types for each security domain
#   - Use descriptive type names with _t suffix
#   - Document each rule with comments
#   - Test policy in development before production
#   - Start with restrictive policy, add permissions as needed
#   - Use default deny-all approach
#   - Regularly review and update policies
#
# ==============================================================================
