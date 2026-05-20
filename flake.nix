{
  description = "Flake for verus";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/687f05a9184cad4eaf905c48b63649e3a86f5433";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "x86_64-windows"
      ];
      eachDefaultSystem = f: builtins.foldl' lib.attrsets.recursiveUpdate { } (map f systems);
    in
    eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        formatter = pkgs.nixpkgs-fmt;
        linters = [ pkgs.statix ];
        # https://github.com/verus-lang/verus/blob/main/rust-toolchain.toml
        rust-bin = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        cvc5' = pkgs.cvc5.override {
          cadical = pkgs.cadical.override { version = "2.0.0"; };
        };
        # https://github.com/verus-lang/verus/blob/main/tools/common/consts.rs
        cvc5 = cvc5'.overrideAttrs (
          finalAttrs: previousAttrs: {
            version = "1.1.2";
            src = pkgs.fetchFromGitHub {
              owner = "cvc5";
              repo = "cvc5";
              tag = "cvc5-${finalAttrs.version}";
              hash = "sha256-v+3/2IUslQOySxFDYgTBWJIDnyjbU2RPdpfLcIkEtgQ=";
            };
          }
        );
      in
      {
        packages.${system} = rec {
          default = verus;
          inherit rust-bin;
          rustup = pkgs.callPackage ./rustup.nix { inherit rust-bin; };
          inherit (verus.passthru) vargo;
          verus = pkgs.callPackage ./verus.nix {
            inherit rust-bin rustup;
            z3 = pkgs.z3.overrideAttrs (
              finalAttrs: previousAttrs: {
                # https://github.com/verus-lang/verus/blob/main/tools/common/consts.rs
                version = "4.12.5";
                src = pkgs.fetchFromGitHub {
                  owner = "Z3Prover";
                  repo = "z3";
                  tag = "z3-${finalAttrs.version}";
                  sha256 = "sha256-Qj9w5s02OSMQ2qA7HG7xNqQGaUacA1d4zbOHynq5k+A=";
                };
              }
            );
          };
          verusfmt = pkgs.callPackage ./verusfmt.nix { };
        };

        formatter.${system} = formatter;

        checks.${system}.lint = pkgs.stdenvNoCC.mkDerivation {
          name = "lint";
          src = ./.;
          doCheck = true;
          nativeCheckInputs = linters ++ lib.singleton formatter;
          checkPhase = ''
            nixpkgs-fmt --check .
            statix check
          '';
          installPhase = "touch $out";
        };

        apps.${system} = {
          update = {
            type = "app";
            program = lib.getExe (
              pkgs.writeShellApplication {
                name = "update";
                runtimeInputs = [ pkgs.nix-update ];
                text = lib.concatMapStringsSep "\n" (package: "nix-update --flake ${package} || true") (
                  builtins.attrNames self.packages.${system}
                );
              }
            );
          };
        };

        devShells.${system}.default =
          (pkgs.mkShellNoCC.override {
            stdenv = pkgs.stdenvNoCC.override {
              initialPath = [ pkgs.coreutils ];
            };
          })
            {
              packages = with self.packages.${system}; [
                rust-bin
                rustup
                vargo
                verus
                verusfmt
                cvc5
              ];
            };
      }
    );
}
