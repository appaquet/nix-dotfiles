{
  # To use, create .envrc with:
  # use flake /home/appaquet/dotfiles/shells/exocore --impure
  # watch_file /home/appaquet/dotfiles/shells/exocore/flake.nix

  description = "exomind";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [ (import rust-overlay) ];
        };

        python3 = ((pkgs.python311.withPackages(p: with p; [ 
          tensorflow 
          grpcio-tools 
          click
          keras
          mypy-protobuf
        ])).override ({ ignoreCollisions = true; }));
      in
      {
        devShells = {
          default = pkgs.mkShell rec {
            buildInputs = with pkgs; [
              clang
              protobuf
              capnproto
              nodejs
              yarn
              nix-ld

              rust-bin.stable.latest.default

              llvmPackages.libclang
              llvmPackages.libcxxClang
              zlib
            ];

            packages = [
              python3
              (pkgs.poetry.override { python3 = pkgs.python311; })
            ];

            NODE_OPTIONS = "--openssl-legacy-provider"; # nodejs SSL error. see https://github.com/NixOS/nixpkgs/issues/209668

            NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
              pkgs.stdenv.cc.cc
              pkgs.clang
              pkgs.llvmPackages.libclang
              pkgs.llvmPackages.libcxxClang
              pkgs.zlib
            ];
            NIX_LD = builtins.readFile "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
          };
        };
      });
}
