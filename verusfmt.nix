{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cargo,
  rustfmt,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "verusfmt";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "verus-lang";
    repo = "verusfmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-H9vD67Jrxrt515Wjd696Aoqc1n5LuxCaSxIXX9dNEZw=";
  };

  cargoHash = "sha256-d13J2xhPDbHH2qyqx/Lnv925bwlqRTUSjqnH5BU7BxE=";

  nativeCheckInputs = [
    cargo
    rustfmt
  ];

  doCheck = true;

  meta = {
    homepage = "https://github.com/verus-lang/verusfmt";
    description = "An Opinionated Formatter for Verus";
    license = lib.licenses.mit;
    mainProgram = "verusfmt";
    maintainers = with lib.maintainers; [ stephen-huan ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
      "x86_64-windows"
    ];
  };
})
