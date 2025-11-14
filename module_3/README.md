# Module 3: QNX IPC Communication Training

This module demonstrates QNX message passing IPC with one receiver and two sender applications.

## Overview

- **Receiver**: Waits for messages on channel `/tmp/qnx_receiver`
- **Sender 1**: Sends 10 messages every 2 seconds with type=1, subtype=100
- **Sender 2**: Sends 7 messages every 3 seconds with type=2, subtype=200

## Directory Structure

```
module_3/
├── BUILD                    # Package marker
├── README.md               # This file
├── build_image.sh          # Build script (executable)
├── run_qemu.sh             # QEMU launcher (executable)
├── src/                    # Source code
│   ├── BUILD               # Bazel build definitions
│   ├── receiver.cpp        # MessageReceiver class
│   ├── sender1.cpp         # MessageSender class (10 msgs, 2s interval)
│   └── sender2.cpp         # MessageSender class (7 msgs, 3s interval)
├── buildfiles/             # QNX build files
│   └── ipc.build           # IFS build configuration
└── images/                 # Generated IFS images (created during build)
    └── ipc.ifs             # Generated QNX IFS image
```

## Building and Running

### Prerequisites

- QNX SDP 8.0 environment sourced
- Bazel configured for QNX cross-compilation
- QEMU installed

### Build All Applications and Create IFS Image

```bash
cd module_3
./build_image.sh
```

This script will:
1. Build all three applications (receiver, sender1, sender2) using Bazel
2. Verify the binaries were created successfully
3. Create the IFS image using mkifs
4. Display image information

### Run in QEMU

```bash
cd module_3
./run_qemu.sh
```

This will:
- Start QEMU with the IFS image
- Automatically launch the receiver
- Start both senders after a 2-second delay
- Display all message exchanges in the console

### Exit QEMU

Press `Ctrl+A`, then `X` to exit QEMU

## Expected Output

When running the demo, you should see:

1. **Receiver Output**:
   - Initialization message with process ID and channel ID
   - Message received notifications showing type, subtype, and data

2. **Sender 1 Output**:
   - Connection confirmation
   - 10 messages sent every 2 seconds
   - Message format: "Hello from SENDER1 - Message #X"
   - Type: 1, Subtype: 100

3. **Sender 2 Output**:
   - Connection confirmation
   - 7 messages sent every 3 seconds
   - Message format: "Greetings from SENDER2 - Message #X"
   - Type: 2, Subtype: 200

## Message Flow

```
Time 0s:    Receiver starts and waits
Time 2s:    Sender1 starts, connects, sends message #1
Time 3s:    Sender2 starts, connects, sends message #1
Time 4s:    Sender1 sends message #2
Time 6s:    Sender1 sends message #3, Sender2 sends message #2
Time 8s:    Sender1 sends message #4
...
```

## Implementation Details

### MessageReceiver (receiver.cpp)

- Uses `name_attach()` to create a named channel
- Implements `MsgReceive()` loop to handle incoming messages
- Sends replies using `MsgReply()`
- Handles both regular messages and pulses

### MessageSender (sender1.cpp, sender2.cpp)

- Uses `name_open()` to connect to the receiver
- Implements retry logic for connection attempts
- Sends messages using `MsgSend()` (synchronous)
- Waits for replies before continuing

### Build Configuration

All binaries are built with:
- `-Wall -Wextra`: Enable all warnings
- `-std=c++14`: C++14 standard
- QNX cross-compilation toolchain (x86_64)

## Learning Objectives

1. Understand QNX message passing IPC
2. Learn how to create named channels
3. Implement client-server communication patterns
4. Handle multiple concurrent senders
5. Work with Bazel build system for QNX
6. Create and deploy QNX IFS images

## References

- QNX Neutrino RTOS System Architecture Guide
- QNX Message Passing API documentation
- Bazel documentation for cross-compilation
