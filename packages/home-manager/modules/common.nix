{ pkgs, ... }:

{
  imports = [
    ./fish/fish.nix
    ./tmux.nix
    ./git/git.nix
    ./neovim/neovim.nix
    ./rtx/rtx.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    tmux

    git
    gh

    bat # cat replacement
    hexyl

    fzf
    ripgrep

    dua
    bottom
    htop

    jq
    jless

    tealdeer # rust version of tldr

    kubectx
    kubectl
    k9s

    dive # docker container explorer

    rustup # don't install cargo, let rustup do the job here

    any-nix-shell # allows using fish for `nix shell`
  ];
}
