{ ... }:

{
  imports = [
    ./modules/base.nix
    ./modules/dev.nix
    ./modules/work
    ./modules/vms.nix
    ./modules/media.nix
    ./modules/exo.nix
    ./modules/docker.nix
  ];

  home.username = "appaquet";
  home.homeDirectory = "/home/appaquet";
  home.stateVersion = "23.11";
}

