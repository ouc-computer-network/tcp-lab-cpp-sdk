# TCP Lab C++ SDK (Standalone)

This repository is a standalone copy of `sdk/cpp` from the [`tcp-lab`](https://github.com/ouc-computer-network/tcp-lab) project. It contains the C++ SDK headers plus a couple of reference implementations that can be compiled into shared libraries and loaded by the Rust simulator.

## Layout

- `include/ouc/tcp/sdk`: public C++ SDK headers (TransportProtocol, SystemContext,
  TcpHeader, Packet, etc.).
- `src/Sender.cpp` / `src/Receiver.cpp`: example protocols showing how to
  implement sender/receiver logic against the SDK.
- `src/main.cpp`: tiny example binary target you can extend for local unit tests.

## Building the shared libraries

```bash
xmake # builds demo binary + lib_sender + lib_receiver
```

Artifacts end up under `build/<plat>/<arch>/<mode>/`.

Key build settings:

- C++20 is enabled (`std::optional`, etc.).
- Targets `rdt3_sender` and `rdt3_receiver` are **shared libraries** so they can
  be dlopen-ed by the Rust simulator.
- On macOS we pass `-undefined dynamic_lookup`, which tells the linker to leave
  the Rust FFI symbols unresolved; they are provided by the simulator process at
  runtime.

If you need Release artifacts use `xmake f -m release && xmake`.

## Continuous Integration

The workflow in `.github/workflows/ci.yml` runs on Linux, macOS, and Windows.
For each platform it:

1. Installs the latest stable Rust toolchain and xmake.
2. Builds the shared `rdt3_sender` / `rdt3_receiver` libraries in Release mode.
3. Locates the freshly built `.so` / `.dylib` / `.dll` files.
4. Clones the upstream `tcp-lab` repository, builds `tcp-lab-cli`, and
   executes the `tests/test_rdt3.toml` scenario while pointing the simulator at
   the two shared libraries via `--cpp-sender-lib` / `--cpp-receiver-lib`.

This ensures every push/PR verifies that the exported C++ protocols can be
dlopen-ed successfully by the Rust simulator on all supported GitHub Actions
platforms.
