# QNX Training: From Beginner to Advanced Security
## Complete Hands-on Guide (C++ Edition with Bazel)

This repository contains a complete QNX training organized into 4 progressive modules. Each module is self-contained with its own source code, Bazel BUILD files, and bootable IFS (Image Filesystem) images.

---

## Repository Structure

```
qnx/
├── module_1/                    # Hello World - Your First QNX Application
│   ├── BUILD                    # Bazel build configuration
│   ├── buildfiles/              # IFS build configuration
│   └── run_qemu.sh              # QEMU launcher script
├── module_2/                    # Extended System with Shell and Tools
│   ├── BUILD                    # Bazel build configuration
│   ├── buildfiles/              # IFS build configuration
│   └── run_qemu.sh              # QEMU launcher script
├── module_3/                    # IPC Communication (Message Passing)
│   ├── BUILD                    # Bazel build configuration
│   ├── buildfiles/              # IFS build configuration
│   ├── README.md                # Module-specific documentation
│   └── run_qemu.sh              # QEMU launcher script
├── module_4/                    # Security Policies and Access Control
│   ├── BUILD                    # Bazel build configuration
│   ├── buildfiles/              # IFS build configuration
│   ├── secpol/                  # Security policy definitions
│   ├── README.md                # Module-specific documentation
│   ├── QUICKSTART.md            # Quick start guide
│   └── run_qemu.sh              # QEMU launcher script
├── module_common/               # Shared applications and build files
│   ├── apps/                    # Reusable C++ applications
│   │   ├── hello_world/         # Simple hello world app
│   │   └── sender_receiver/     # IPC demo apps (receiver, sender1, sender2)
│   └── buildfiles/              # Common IFS build components
├── toolchains_qnx/              # Bazel toolchain configuration
│   ├── toolchains/              # QCC cross-compilation toolchain
│   ├── rules/fs/                # IFS build rules
│   ├── platforms/               # Platform definitions (x86_64)
│   └── README.md                # Toolchain documentation
├── .bazelrc                     # Bazel configuration
├── MODULE.bazel                 # Bazel module definition
├── TRAINING.md                  # Detailed training guide
└── README.md                    # This file
```

---

## Quick Start

### Prerequisites

- **QNX SDP 8.0** installed at `/home/qnx/qnx800`
- **Bazel 8.0+** build system installed
- **QEMU** for x86_64 emulation (`qemu-system-x86_64`)
- **Linux development machine** (tested on Ubuntu/WSL2)

### Build and Run Modules with Bazel

All modules use Bazel for building. The general pattern is:

```bash
# Build the IFS image
bazel build //module_N:MODULE_NAME_ifs

# Run in QEMU
bazel run //module_N:run_qemu
```

### Specific Module Commands

```bash
# Module 1: Hello World
bazel run //module_1:run_qemu

# Module 2: Extended System
bazel run //module_2:run_qemu

# Module 3: IPC Communication
bazel run //module_3:run_qemu

# Module 4: Security Policies
bazel run //module_4:run_qemu
```

See [TRAINING.md](TRAINING.md) for complete step-by-step documentation.

---

## Module Overview

### Module 1: Hello World 👋
**Duration:** 15-30 minutes
**Learning Objectives:**
- Build a simple C++17 application for QNX using Bazel
- Create a minimal bootable QNX IFS image (< 2MB)
- Run QNX in QEMU emulator
- Understand basic QNX image structure
- Learn modern C++ organization with header/implementation separation

**Key Components:**
- `module_common/apps/hello_world/qnx_application.h` - Application class header
- `module_common/apps/hello_world/qnx_application.cpp` - Implementation
- `module_common/apps/hello_world/main.cpp` - Entry point
- `module_1/buildfiles/qnx_minimal.build` - Minimal IFS configuration with procnto and ksh
- `module_1/BUILD` - Bazel build rules for IFS generation

**What You'll See:**
- QNX kernel boot sequence
- Hello World output with process information
- Automatic system exit after completion

**Build & Run:**
```bash
bazel run //module_1:run_qemu
```

---

### Module 2: Extended System 🛠️
**Duration:** 30-45 minutes
**Learning Objectives:**
- Extend QNX image with comprehensive utilities
- Use ksh shell interactively
- Work with toybox Unix utilities
- Understand QNX system services

**Features:**
- **Shell:** ksh (Korn shell) with full scripting support and job control
- **Toybox utilities:** ls, cat, cp, mv, rm, mkdir, chmod, touch, grep, sed, awk, ps
- **QNX-specific tools:** pidin, slay, slogger2, nice, renice
- **System services:** slogger2 (system logger), pci-server, random daemon
- **Libraries:** Full libc, libc++, libm, libsocket support

**What You'll See:**
- Interactive shell prompt
- Full Unix-like environment
- System process listing with pidin
- File system operations

**Build & Run:**
```bash
bazel run //module_2:run_qemu
```

---

### Module 3: IPC Communication 📡
**Duration:** 45-60 minutes
**Learning Objectives:**
- Implement QNX native message passing IPC
- Create message channels with `name_attach()`
- Connect to channels with `name_open()`
- Send/receive synchronous messages
- Handle multiple concurrent clients
- Use C++17 features: smart pointers, RAII, optional, chrono

**Components:**
- `module_common/apps/receiver/` - Secure Message Receiver
  - `secure_message_receiver.h` - Receiver class header with RAII
  - `secure_message_receiver.cpp` - Implementation with unique_ptr
  - `main.cpp` - Entry point
  - Creates named channel with automatic cleanup
  - Receives messages from multiple senders
  - Displays message type, subtype, and data
- `module_common/apps/sender_a/` - Sender A (Authorized)
  - `message_sender.h` - Sender class with connection management
  - `message_sender.cpp` - Implementation with optional and chrono
  - `main.cpp` - Entry point
  - Sends 10 messages (type=1, subtype=100)
  - 2-second intervals using std::chrono
- `module_common/apps/sender_b/` - Sender B (Unauthorized)
  - Same structure as sender_a
  - Sends 7 messages (type=2, subtype=200)
  - 3-second intervals
  - Demonstrates concurrent IPC

**What You'll See:**
- Receiver starting and waiting for messages
- Sender1 sending messages every 2 seconds
- Sender2 sending messages every 3 seconds
- Interleaved message reception and acknowledgment
- Clean process termination

**Build & Run:**
```bash
bazel run //module_3:run_qemu
```

**Key Concepts:**
- Channel creation and naming
- Connection IDs (coid) and Receive IDs (rcvid)
- Synchronous message passing (blocking)
- Message structure design
- RAII for resource management (unique_ptr with custom deleter)
- std::optional for safer return values
- std::chrono for time management

---

### Module 4: Security Policies 🔒
**Duration:** 60-90 minutes
**Learning Objectives:**
- Configure QNX Adaptive Partitioning security policies
- Implement mandatory access control (MAC)
- Define security types for processes
- Control IPC channel access
- Demonstrate authorized vs unauthorized access
- Enable security policy enforcement with `secpolpush`

**Components:**
- `module_common/apps/sender_receiver/receiver.cpp` - Secure receiver (type: receiver_secure_t)
  - Creates secured channel with type enforcement
  - Only accepts connections from authorized senders
  - Logs security policy decisions
- `module_common/apps/sender_receiver/sender1.cpp` - Authorized sender (type: sender1_secure_t)
  - **ALLOWED** to connect per security policy
  - Successfully sends all messages
  - Demonstrates authorized IPC
- `module_common/apps/sender_receiver/sender2.cpp` - Unauthorized sender (type: sender2_secure_t)
  - **DENIED** by security policy
  - Connection attempts fail
  - Demonstrates policy enforcement
- **Modular Security Policy** - Split into per-component fragments:
  - `module_common/apps/receiver/receiver.secpol` - Defines receiver_secure_t type
  - `module_common/apps/sender_a/sender_a.secpol` - Defines sender_a_secure_t, ALLOW rule
  - `module_common/apps/sender_b/sender_b.secpol` - Defines sender_b_secure_t, no ALLOW rule
  - `module_4/secpol/BUILD` - Compiles fragments into secpol.bin
  - Benefits: Co-located with code, easy to maintain, scalable

**What You'll See:**
- Security policy enforcement enabled via `secpolpush`
- Receiver starting with security type
- Sender1 successfully connecting and sending messages
- Sender2 connection failures with "No such process" error
- Policy-based access control in action

**Build & Run:**
```bash
bazel run //module_4:run_qemu
```

**Key Concepts:**
- Security policy language (`.sp` files)
- `secpolcompile` - Policy compilation
- `secpolpush` - Enable policy enforcement
- `on -T <type>` - Launch processes with security types
- `allow_attach` - Control channel name attachment
- `allow <type1> <type2>:channel connect` - Control channel connections
- Default deny-all policy model

**Security Policy Syntax:**
```
type receiver_secure_t;
type sender1_secure_t;
type sender2_secure_t;

allow_attach receiver_secure_t /dev/name/local/qnx_receiver_secure;
allow sender1_secure_t receiver_secure_t:channel connect;
# sender2 implicitly denied
```

---

## Architecture

### Bazel Build System

All modules use a centralized Bazel toolchain configuration in `toolchains_qnx/`:

**Directory Structure:**
```
toolchains_qnx/
├── toolchains/
│   ├── qcc/                # QNX C/C++ compiler toolchain
│   │   ├── BUILD           # Toolchain targets
│   │   └── cc_toolchain_config.bzl  # Compiler flags, features
│   └── fs/                 # Filesystem toolchain
│       ├── BUILD           # IFS toolchain registration
│       └── toolchain.bzl   # IFS build implementation
├── rules/
│   └── fs/
│       ├── ifs.bzl         # qnx_ifs() rule definition
│       └── BUILD
├── platforms/
│   └── BUILD               # x86_64-qnx platform definition
└── extensions.bzl          # Bazel module extension
```

**Key Features:**
- **Cross-compilation:** QCC wrapper for QNX target compilation
- **C++ Standard:** C++17 with full STL support
- **Compiler:** QCC 8.3.0 (GCC-based)
- **Sandboxing:** Enabled with QNX license directory mounting
- **IFS Generation:** Custom Bazel rule (`qnx_ifs`) for building bootable images
- **Modern C++:** Smart pointers, RAII, optional, string_view

**Compiler Flags:**
- `-O2` - Optimization level 2
- `-Wall -Wextra` - Comprehensive warnings
- `-std=c++17` - C++17 standard
- `-fno-exceptions` - No C++ exceptions (embedded)
- `-fno-rtti` - No runtime type information

**Platform:**
- `//toolchains_qnx/platforms:x86_64-qnx` - QNX x86_64 target
- CPU: `x86_64`
- Constraint: `@platforms//os:qnx`

### QNX IFS (Image Filesystem) Build Process

**IFS Build Rule (`qnx_ifs` in rules/fs/ifs.bzl):**

The custom `qnx_ifs` Bazel rule generates bootable QNX images:

```python
qnx_ifs(
    name = "example_ifs",           # Target name
    srcs = [                        # Input files (binaries, libs, policies)
        "//app:my_app",
        "//common:tools_build",
    ],
    out = "example.ifs",            # Output IFS filename
    build_file = "//path:example_build",  # IFS configuration (.build file)
    ext_repo_maping = {             # Variable substitutions
        "APP_PATH": "$(location //app:my_app)",
    },
)
```

**Parameters:**
- `srcs`: List of binary dependencies (compiled apps, libraries)
- `out`: Output IFS image filename (`.ifs` extension)
- `build_file`: IFS configuration file (`.build` format)
- `ext_repo_maping`: Key-value substitutions for build file variables

**Build Process:**
1. Compile C++ applications with QCC toolchain
2. Collect dependencies (binaries, libraries, config files)
3. Substitute variables in `.build` file
4. Run `mkifs` to create bootable IFS image
5. Output: Single bootable `.ifs` file containing entire system

**IFS Build File Format (`.build` files):**

IFS build files define the image contents and boot configuration:

```bash
# Image size allocation
[image=0x200000]

# Boot section - what runs at startup
[virtual=x86_64,multiboot] boot = {
    startup-x86 -D 8250          # Startup program with serial driver
    PATH=/proc/boot:/bin         # System PATH
    LD_LIBRARY_PATH=/proc/boot:/lib  # Library search path
    procnto-smp-instr            # QNX microkernel (SMP, instrumented)
}

# Startup script - runs after kernel boot
[+script] startup-script = {
    slogger2 &                   # Start system logger
    /proc/boot/my_app &          # Start custom application
    [+session] ksh &             # Start interactive shell
}

# Application binaries
my_app=${APP_PATH}               # Variable substitution from Bazel

# Include common utilities
[+include] common/tools.build
```

**Key Sections:**
- `[image=SIZE]`: Allocate image size
- `[virtual=ARCH,multiboot] boot`: Boot configuration
- `[+script] startup-script`: Init script
- `[+session]`: Interactive session (with TTY)
- `[+include]`: Include other build files
- `[type=link]`: Create symbolic links
- Variable expansion: `${VAR_NAME}` from `ext_repo_maping`

---

## Environment Setup

### Automatic Setup (Recommended)

The Bazel build system automatically configures the QNX environment. Just ensure QNX SDP 8.0 is installed at `/home/qnx/qnx800`.

**Environment Variables (automatically set by Bazel):**
```bash
QNX_HOST=/home/qnx/qnx800/host/linux/x86_64
QNX_TARGET=/home/qnx/qnx800/target/qnx
QNX_CONFIGURATION=/home/qnx/.qnx
PATH=$QNX_HOST/usr/bin:$PATH
```

### Manual Environment Setup (Optional)

For manual command-line work outside Bazel:

```bash
# Create environment setup script
cat > ~/qnx_env.sh << 'EOF'
#!/bin/bash
export QNX_HOST=/home/qnx/qnx800/host/linux/x86_64
export QNX_TARGET=/home/qnx/qnx800/target/qnx
export QNX_CONFIGURATION=/home/qnx/.qnx
export PATH=$QNX_HOST/usr/bin:$PATH
echo "QNX environment configured:"
echo "  QNX_HOST: $QNX_HOST"
echo "  QNX_TARGET: $QNX_TARGET"
EOF

chmod +x ~/qnx_env.sh
source ~/qnx_env.sh
```

### Bazel Configuration (`.bazelrc`)

The `.bazelrc` file configures Bazel for QNX builds:

```bash
# QNX x86_64 platform
build --platforms=//toolchains_qnx/platforms:x86_64-qnx

# Sandbox configuration for QNX license
build --experimental_writable_outputs
build --sandbox_add_mount_pair=/home/qnx/.qnx

# Execution strategy
build --spawn_strategy=local
build --genrule_strategy=local

# Disable remote caching (local builds)
build --remote_cache=
```

**Key Settings:**
- `--platforms`: Sets target platform to QNX x86_64
- `--sandbox_add_mount_pair`: Mounts QNX license directory in sandbox
- `--spawn_strategy=local`: Runs builds locally (not sandboxed)
- `--experimental_writable_outputs`: Allows writing to output directories

---

## Troubleshooting

### Build Failures

#### License Issues
```bash
# Error: "license check failed"
# Solution: Check QNX license file
ls -la ~/.qnx/license/

# Ensure license file exists and is readable
chmod 644 ~/.qnx/license/licenses
```

#### QNX_TARGET Not Found
```bash
# Error: "QNX_TARGET not found"
# Solution: Verify QNX SDP installation
ls -la /home/qnx/qnx800/target/qnx

# If missing, install QNX SDP 8.0
```

#### Bazel Cache Issues
```bash
# Clean Bazel cache and rebuild
bazel clean --expunge
bazel build //module_1:qnx_minimal_ifs
```

### QEMU Issues

#### QEMU Not Found
```bash
# Check QEMU installation
qemu-system-x86_64 --version

# Install if missing (Ubuntu/Debian)
sudo apt update
sudo apt install qemu-system-x86

# Install if missing (Fedora/RHEL)
sudo dnf install qemu-system-x86
```

#### QEMU Hangs on Boot
```bash
# Issue: Black screen, no output
# Solution: Check QEMU parameters in run_qemu.sh
# Ensure: -serial stdio -display none are set

# Try with different CPU model
qemu-system-x86_64 -kernel module_1/qnx_minimal.ifs \
  -cpu max -m 2048 -serial stdio -display none -no-reboot
```

#### QEMU Exits Immediately
```bash
# Check IFS image integrity
ls -lh module_1/qnx_minimal.ifs

# Re-build the image
bazel clean
bazel build //module_1:qnx_minimal_ifs
bazel run //module_1:run_qemu
```

### Runtime Issues

#### Processes Failing to Start
```bash
# Error: "Unable to start XYZ (2)"
# Cause: Binary not included in IFS or missing dependencies

# Solution: Check .build file includes the binary
# Verify dependencies in BUILD file srcs list
```

#### IPC Connection Failures (Module 3)
```bash
# Error: "Connection attempt failed, retrying..."
# Cause: name_attach() called with incorrect path

# Solution: Use simple names, not paths
# Correct: name_attach(NULL, "qnx_receiver", 0)
# Wrong: name_attach(NULL, "/tmp/qnx_receiver", 0)
```

#### Security Policy Not Enforced (Module 4)
```bash
# Issue: sender2 connects when it should be denied
# Cause: secpolpush not called or policy not loaded

# Solution: Verify in .build file:
# 1. secpol.bin is included at /proc/boot/
# 2. secpolpush is called before starting processes
# 3. Processes started with: on -T <type> /proc/boot/app
```

---

## Learning Path

**Recommended Order:**

1. **Module 1 - Hello World** (15-30 min)
   - Get comfortable with basic QNX application development
   - Understand IFS image structure and Bazel builds
   - Learn QEMU usage

2. **Module 2 - Extended System** (30-45 min)
   - Explore QNX system utilities and shell
   - Understand system services and daemons
   - Work with interactive ksh shell

3. **Module 3 - IPC Communication** (45-60 min)
   - Learn QNX-specific message passing IPC
   - Implement synchronous communication
   - Handle multiple concurrent clients

4. **Module 4 - Security Policies** (60-90 min)
   - Understand mandatory access control
   - Write security policy definitions
   - Implement authorized/unauthorized access patterns

**Total Time:** ~3-4 hours for complete training

**Prerequisites by Module:**
- Module 1: None
- Module 2: Module 1 completed
- Module 3: Module 2 completed, understand IPC concepts
- Module 4: Module 3 completed, understand QNX security model

---

## Additional Documentation

- **[TRAINING.md](TRAINING.md)** - Detailed step-by-step training guide with explanations
- **Module READMEs:**
  - [Module 3: IPC Communication](module_3/README.md)
  - [Module 4: Security Policies](module_4/README.md)
- **[toolchains_qnx/README.md](toolchains_qnx/README.md)** - Bazel toolchain documentation

---

## Support and Resources

- **QNX Official Documentation:** https://www.qnx.com/developers/docs/8.0/
- **QNX Community Forums:** https://community.qnx.com/
- **Bazel Documentation:** https://bazel.build/
- **QNX Security System:** https://www.qnx.com/developers/docs/8.0/com.qnx.doc.security.system/

### Useful QNX Commands

**System Information:**
```bash
pidin info                    # System information
pidin mem                     # Memory usage
uname -a                      # Kernel version
```

**Process Management:**
```bash
pidin                         # List all processes
slay process_name             # Kill process by name
slay -9 PID                   # Force kill by PID
nice -n 10 command            # Run with priority
```

**System Logs:**
```bash
slog2info                     # View system logs
slog2info -w                  # Watch logs (follow mode)
```

---

## License and Copyright

**Training Materials:**
Educational purposes only.

**QNX Neutrino RTOS:**
© QNX Software Systems Limited. All rights reserved.
QNX, QNX Neutrino, and related marks are trademarks of BlackBerry Limited.

---

## Contributing

This is a training repository. If you find issues or have improvements:

1. Document the problem clearly
2. Provide steps to reproduce
3. Suggest a fix with explanation
4. Test thoroughly across all affected modules

---

**Happy Learning! 🚀**

*This comprehensive training takes you from basic QNX development to advanced security features, providing hands-on experience with real-world QNX Neutrino RTOS concepts.*

---

**Quick Reference Card:**

| Module | Time | Key Topic | Command |
|--------|------|-----------|---------|
| 1 | 30m | Hello World | `bazel run //module_1:run_qemu` |
| 2 | 45m | System Tools | `bazel run //module_2:run_qemu` |
| 3 | 60m | IPC | `bazel run //module_3:run_qemu` |
| 4 | 90m | Security | `bazel run //module_4:run_qemu` |

**Next Steps:** Start with `bazel run //module_1:run_qemu` and follow the [TRAINING.md](TRAINING.md) guide!
