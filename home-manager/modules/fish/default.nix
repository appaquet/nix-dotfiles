{ config, pkgs, libs, ... }:

{
  programs.fish = {
    enable = true;
    package = pkgs.fish;

    interactiveShellInit = ''
      # Disable greeting
      set fish_greeting

      # vi mode
      fish_vi_key_bindings

      # Add support for nix run and nix-shell in fish
      any-nix-shell fish --info-right | source

      set EDITOR nvim

      # Term color support + theme
      set -x TERM xterm-256color
      set -g theme_display_cmd_duration no
      set -g theme_display_date no
      set -g theme_color_scheme base16 # Use `bobthefish_display_colors --all` to list themes

      # Paths
      # We don't use the normal fish_user_paths because it slows down everything in the config.fish
      # See https://github.com/fish-shell/fish-shell/issues/2688
      set -x PATH ~/bin $PATH

      # Source any local stuff from .profile
      if test -f ~/.profile
        fenv source ~/.profile
      end
    '';

    plugins = [
      {
        name = "bobthefish";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "theme-bobthefish";
          rev = "2dcfcab653ae69ae95ab57217fe64c97ae05d8de";
          sha256 = "118hj100c4bb8hyhr22mrsjhg97pyd24cwb1l39bhryd0k9yc5lc";
        };
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "foreign-env";
        src = pkgs.fishPlugins.foreign-env.src;
      }
    ];

    shellAliases = {
      gs = "git status";
      l = "ls";
      k = "kubectl";
      randstr = "randstr 'tr -cd \"[:alnum:]\" < /dev/urandom | fold -w30 | head -n1'";
    };

    shellAbbrs = {
      gs = "git status";
      gls = "git log --stat";
      glm = "git log --merges --first-parent";
      gd = "git diff";
      gds = "git diff --staged";
      gp = "git pull";
      gck = "git checkout";
      gcm = "git commit -m";
      gchm = "git commit -m (git log -1 --pretty=format:%s)";
      gpom = "git pull origin master";
      gpr = "git pull --rebase --autostash";
      gca = "git commit --amend";
      gr = "git rev-parse --short=7 @";
      gb = "git for-each-ref --sort=-committerdate refs/heads/ --format=\"%(color: red)%(committerdate:short) %(color: 244) - - %(color: cyan)%(refname:short) %(color: 244) - - %(color: green)%(subject) \"";
      grsw = "git restore --staged --worktree";
      grws = "git restore --staged --worktree";
      grs = "git restore --staged";
      ghpr = "gh pr create --draft --body \"\" --title";
      gts = "git tag --sort version:refname";
    };
  };
}
