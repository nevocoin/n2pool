{
  description = "Decentralized pool for Nevocoin mining.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
    let
    pkgs = import nixpkgs { inherit system; };
    in
    rec {
      packages = utils.lib.flattenTree {
        n2pool =  pkgs.stdenv.mkDerivation {
          pname = "n2pool";
          version = "0.0.1";
          src = self;

          nativeBuildInputs = builtins.attrValues {
            inherit (pkgs) cmake pkg-config;
          };

          buildInputs = builtins.attrValues {
            inherit (pkgs) libuv zeromq libsodium gss curl;
          };

          cmakeFlags = ["-DWITH_LTO=OFF"];

          installPhase = ''
            mkdir -p $out/bin
            cp -r ./n2pool $out/bin/
          '';
        };
      };

      defaultPackage = packages.n2pool;
    }
  );
}
