{ pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./tmux
    ./git
    ./neovim
    ./mise
    ./utils
    ./autojump.nix
    ./ssh.nix
  ];

  programs.home-manager.enable = true;

  # https://github.com/nix-community/nix-direnv#via-home-manager
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Notes: 
  #  - not everything is installed using nix. some tools are install via `mise` when different versions are required (see ./rtx/tool-versions)
  #  - to install an unstable package, use `unstablePkgs.<package-name>`
  home.packages = with pkgs; [
    manix # nix doc cli searcher
    nix-output-monitor # better nix build output (nom)
    nixpkgs-fmt
    libtree # recursive ldd 
    fzf-nix # fzf-nix
    nvd # nix package diff tool

    direnv
    nix-direnv

    git
    gh

    bat # cat replacement
    hexyl

    fzf
    ripgrep
    fd # replacement for find

    dua
    bottom
    btop
    htop
    stress

    ookla-speedtest
    mtr
    gping
    neofetch
    bandwhich
    dig
    whois

    jq
    jless

    zip
    unzip
    pigz
    gzip
    bzip2
    gnutar

    curl
    wget

    tealdeer # rust version of tldr

    rsync
    rclone
  ];
}
