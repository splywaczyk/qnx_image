# QNX 8 Hello World Application with Bazel

This project contains a Hello World application for QNX 8 built with Bazel.

## Project Structure

```
.
├── app/
│   ├── BUILD          # Build configuration for the application
│   └── hello.cpp      # Hello World C++ source code
├── bazel/
│   ├── toolchains/    # QNX toolchain definitions
│   │   ├── BUILD      # Toolchain configurations
│   │   ├── qnx_toolchain.bzl  # Toolchain rule implementation
│   │   └── qcc_wrapper.sh     # QCC compiler wrapper script
│   └── platforms/     # Platform definitions
│       └── BUILD      # QNX platform definitions (x86_64, aarch64)
├── third_party/
│   ├── qnx/           # QNX SDP integration
│   └── variables.bzl  # QNX SDP path configuration
├── .bazelrc           # Bazel configuration
└── WORKSPACE          # Bazel workspace definition

```

## Built Application

The application has been successfully built:
- **Binary**: `bazel-bin/app/hello`
- **Type**: ELF 64-bit executable for x86-64
- **Target**: QNX 8 (uses QNX dynamic linker `/usr/lib/ldqnx-64.so.2`)
- **Size**: 7.4K

## Building the Application

### Build for x86_64 (default):
```bash
bazel build //app:hello
```

### Build for aarch64:
```bash
bazel build //app:hello --config=aarch64
```

## Configuration Details

### QNX SDP Settings
- **Path**: `/home/qnx/qnx800`
- **Version**: QNX 8.0.0
- **Architectures**: x86_64, aarch64

### Toolchain Features
- Automatic QNX environment variable setup (QNX_HOST, QNX_TARGET, QNX_CONFIGURATION)
- License file detection from `~/.qnx/license/`
- Argument reordering for QCC compatibility
- Filtering of unsupported GCC flags

### Build Flags
- Local execution (no sandboxing) due to QNX license requirements
- Disabled dependency file generation (QNX qcc incompatibility)
- Cross-compilation support for both x86_64 and aarch64

## Running on QEMU

To run the application on QEMU, you'll need to:
1. Transfer the binary to your QNX 8 QEMU image
2. Execute it on the QNX system:
   ```bash
   ./hello
   ```

Expected output:
```
Hello World from QNX 8!
Running on QEMU
```

## Modifying the Application

Edit `app/hello.c` to modify the application, then rebuild with:
```bash
bazel build //app:hello
```

## Toolchain Components

- **Compiler**: QNX qcc with GCC 12.2.0
- **Wrapper Script**: `bazel/toolchains/qcc_wrapper.sh` handles environment setup and flag filtering
- **Platforms**: Configured for QNX x86_64 and aarch64 targets

## Security Policies

The project includes QNX security policies (secpol) for IPC communication:

- **Location**: `config/secpol/`
- **Policy File**: `ipc_policy.sp` - Defines security types and permissions for sender/receiver communication
- **Features**:
  - Domain transitions for sender_t and receiver_t types
  - Socket creation, binding, and connection permissions
  - Channel communication abilities
  - Unix domain socket access controls

### Using Security Policies

Compile the policy:
```bash
secpolcompile -o ipc_policy.bin config/secpol/ipc_policy.sp
```

Load at runtime:
```bash
secpol -l ipc_policy.bin
```

See `config/secpol/README.md` for detailed documentation.
