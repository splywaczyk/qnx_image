# Bazel toolchains for QNX

This module implements support for [QNX SDP 8.0](https://www.qnx.com/products/everywhere/index.html)

## Usage

MODULE.bazel
```
bazel_dep(name = "score_toolchains_qnx", version = "0.1")

toolchains_qnx = use_extension("@score_toolchains_qnx//:extensions.bzl", "toolchains_qnx")
toolchains_qnx.sdp(
    url = "http://example.com/qnx800.tar.gz",
    sha256 = "<package sha256>",
)

use_repo(toolchains_qnx, "toolchains_qnx_sdp")
use_repo(toolchains_qnx, "toolchains_qnx_qcc")

register_toolchains("@toolchains_qnx_qcc//:qcc_x86_64")
```

.bazelrc
```
build:x86_64-qnx --incompatible_strict_action_env
build:x86_64-qnx --platforms=@score_toolchains_qnx//platforms:x86_64-qnx
build:x86_64-qnx --sandbox_writable_path=/var/tmp
```

```/var/tmp``` needs to be writeable inside of the sandbox because of the license management done by the QNX tools.

## Where to obtain the QNX 8.0 SDP

Follow the tutorial to obtain the SDP and corresponding license and install SDP via Software Center: 
- https://www.youtube.com/watch?v=DtWA5E-cFCo
- https://www.youtube.com/watch?v=s8_rvkSfj10

The QNX SDP is by default installed to ```~/qnx800```.
The archive of this directory is the input for the toolchains_qnx extension.

It is currently assumed that the license is deployed to ```/opt/score_qnx/license/licenses```.
By default QNX tooling installs the license in ```~/.qnx/license/licenses```.

## Using pre-packaged QNX 8.0 SDP

Pre-packaged SDP requires authentication with ones QNX login and password.
For this the ```tools/qnx_credential_helper.py``` needs to be used.

The credential helper is a standalone application and cannot be referenced as Bazel target.
For this the credential helper needs to be put:

- as an absolute path:
```
common --credential_helper=*.qnx.com=/path/to/qnx_credential_helper.py
```

- in $PATH and referenced as:
```
common --credential_helper=*.qnx.com=qnx_credential_helper.py
```

- in your module source and referenced as:
```
common --credential_helper=*.qnx.com=%worksapce%/path/to/qnx_credential_helper.py
```

The credentials are taken from .netrc or from enviroment variables ```SCORE_QNX_USER``` and ```SCORE_QNX_PASSWORD```.


# Repository layout (testing bits)

```
tests/
  BUILD
  init_rpi4.build           # QNX buildfile for aarch64
  init_x86_64.build         # QNX buildfile for x86_64
  run_qemu.sh               # Wrapper to launch QEMU with our IFS + DTB
  third_party/
    qemu-aarch64/
      bin/qemu-system-aarch64
      share/qemu/...        # (keymaps/pc-bios as needed by your build)
    raspi/
      boot-files/bcm2711-rpi-4-b.dtb
```

---

## Why a custom QEMU for aarch64?

Ubuntu 24.04’s packaged QEMU does not ship the `-M raspi4b` machine with BCM2711 peripherals needed for QNX bring-up on RPi 4. We therefore build the QEMU described in the Medium post above and add just the artifacts we need:

- `third_party/qemu-aarch64/bin/qemu-system-aarch64`
- `third_party/qemu-aarch64/share/qemu/*` assets such as keymaps / pc-bios
- RPi4 DTB: `third_party/raspi/boot-files/bcm2711-rpi-4-b.dtb`

This makes the flow reproducible and independent of the host’s system QEMU.

---

## Building the IFS

We use a small Bazel rule (`qnx_ifs`) that wraps `mkifs`. For aarch64 we also pass `-r install` so the buildfile can reference staged files relative to `install/`.

Key points:
- The aarch64 image pulls in the RPi4 BSP’s `startup-bcm2711-rpi4`.
- `main_cpp` is placed at `/usr/bin/main_cpp` inside the image (staged from `bazel-bin/install/usr/bin/main_cpp`).

Typical build:

```bash
bazel build //...   --config=aarch64-qnx
```

---

## Running under QEMU (aarch64)

We launch with the RPi4 machine, our DTB, and the IFS:

```bash
bazel run //tests:run_qemu
# Internally runs something like:
# third_party/qemu-aarch64/bin/qemu-system-aarch64 \
#   -M raspi4b \
#   -kernel bazel-bin/init_aarch64.ifs \
#   -dtb third_party/raspi/boot-files/bcm2711-rpi-4-b.dtb \
#   -append "startup-bcm2711-rpi4 -vvv -D miniuart" \
#   -serial stdio \
#   -nographic -d unimp -s
```

On boot, `main_cpp` executes and prints a “Hello” to the console.

---

## x86_64 vs aarch64 (BUILD multiplexing)

We use `config_setting` to multiplex:
- **x86_64**: builds an x86_64 IFS and uses the host QEMU for x86 experiments.
- **aarch64**: builds the RPi4 IFS and runs with the vendored QEMU + DTB above.

This keeps one workspace supporting both flows cleanly.

---

## Credits

- QEMU RPi4 approach and DTB based on this article https://olof-astrand.medium.com/more-experiments-with-qnx-and-qemu-d24fa1961d9c
