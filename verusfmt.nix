{ lib
, rustPlatform
, fetchFromGitHub
, cargo
, rustfmt
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "verusfmt";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "verus-lang";
    repo = "verusfmt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+NHI2dvCxEGVIUF9zO2aVvVbPSLRtsHFCIHU4cfRzUY=";
  };

  cargoHash = "sha256-8r8PzBrYZWibeFDh2nENctEEkigUzQeD9uD0Jl/Nv5U=";

  nativeCheckInputs = [ cargo rustfmt ];

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
