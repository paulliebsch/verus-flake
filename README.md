# verus-flake

Flake packaging [verus](https://github.com/verus-lang/verus).
Source build version of
[JakeGinesin/verus-flake](https://github.com/JakeGinesin/verus-flake) (binary).

The following packages are exposed through `verus-flake.packages.${system}`
as well as through a devshell `devShells.${system}.default`.

- `rust-bin`: Pinned Rust toolchain (`rustc`, `rustfmt`, etc.).
- `rustup`: Fake `rustup` for spoofing purposes (we use the toolchain above).
- `vargo`: Verus's `cargo` wrapper.
- `verus`: Verus build (`verus`, `rust_verify`, `cargo-verus`, `z3`).
- [`verusfmt`](https://github.com/verus-lang/verusfmt): Verus's `rustfmt`.

Since we build our own Rust toolchain with
[rust-overlay](https://github.com/oxalica/rust-overlay),
`rustup` is not necessary and `verus` works without it.
