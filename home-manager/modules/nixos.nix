{ pkgs, ... }:

{
  # TODO: Should probably be moved...
  home.packages = with pkgs; [
    nix-alien # runs unpatched binaries. either through a FHS, or using nix-ld
    steam-run
  ];
}
