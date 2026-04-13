{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeBinaryWrapper,
  rust-bin,
  rustup,
  z3,
}:

let
  src = fetchFromGitHub {
    owner = "verus-lang";
    repo = "verus";
    rev = "150498b14e93093572997366ef2606511dee2715";
    # tag = "release/${version}";
    hash = "sha256-a+LCUW8MIWXi2A7i6eEYVUPuLhD0Z8EchMxWUGN3vUI=";
  };
  vargo = rustPlatform.buildRustPackage (finalAttrs: {
    pname = "vargo";
    inherit version src;

    sourceRoot = "source/tools/vargo";

    cargoHash = "sha256-0WJEW3FtoWxMaedqBoCmaS0HLsLjxtBlBClAXcjf/6s=";

    meta = meta // {
      mainProgram = "vargo";
    };
  });
  meta = {
    homepage = "https://github.com/verus-lang/verus";
    description = "Verified Rust for low-level systems code";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stephen-huan ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "x86_64-windows"
    ];
  };
in
rustPlatform.buildRustPackage {
  pname = "verus";
  inherit version src;

  sourceRoot = "source/source";

  cargoHash = "sha256-OTPCMsgwhRK7LKuO5R2c5wY+T00g1/50tK6ImZ7Y/yw=";

  nativeBuildInputs = [
    makeBinaryWrapper
    rust-bin
    rustup
    vargo
    z3
  ];

  buildInputs = [
    rustup
    z3
  ];

  buildPhase = ''
    runHook preBuild

    ln -s ${lib.getExe z3} ./z3
    vargo build --release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r target-verus/release -T $out

    mkdir -p $out/bin
    ln -s $out/verus $out/bin/verus
    ln -s $out/rust_verify $out/bin/rust_verify
    ln -s $out/cargo-verus $out/bin/cargo-verus
    ln -s $out/z3 $out/bin/z3

    wrapProgram $out/bin/verus --prefix PATH : ${lib.makeBinPath [ rustup ]}

    runHook postInstall
  '';

  # no tests, verified when built
  doCheck = false;

  passthru = { inherit vargo; };

  meta = meta // {
    mainProgram = "verus";
  };
}
