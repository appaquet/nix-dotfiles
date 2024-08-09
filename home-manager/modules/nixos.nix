{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nix-alien

    gnumake
    nodejs # needed for copilot

    bintools # ld, objdump, etc.
  ];
}
