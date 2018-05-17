{pkgs, ...}:
let stable = import <nixos_stable> {};
in {
  nixpkgs.config = { allowUnfree = true; };
  home.packages = [
    pkgs.jetbrains.idea-community
    pkgs.jetbrains.clion
  ];
  programs.neovim = {
    enable = true;
    configure = {
       customRC = ''
         set tabstop=2 shiftwidth=2 expandtab
       ''; 
    };
  };
  programs.git = {
    enable = true;
    userName = "Tianyi Wang";
    userEmail = "tianyi@apache.org";
    extraConfig = ''
      [credential]
      helper = cache --timeout=3600
      [core]
      editor = nvim
    '';
  };
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
      export NIX_PATH=nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs:nixos_stable=$HOME/.nix-defexpr/channels/nixos_stable
      function ienv {
        export IMPALA_HOME=~/projects/impala
        export JAVA_HOME="$(command -v javac|xargs readlink -f|xargs dirname|xargs dirname)"
        . "$IMPALA_HOME/bin/impala-config.sh"
        if [ "''${BUILD_FARM+x}" ]; then
          sudo ln -s $IMPALA_HOME/toolchain /opt/Impala-Toolchain
          . "''${IMPALA_HOME}"/bin/distcc/distcc_env.sh
          switch_compiler distcc
        fi
        export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:"$LD_LIBRARY_PATH"
        alias b="$IMPALA_HOME/buildall.sh -ninja -noclean -notests"
        alias ish="impala-shell.sh"
        alias ah="cd $IMPALA_HOME"
        alias r="git fetch origin master && git rebase origin/master"
        alias s="gsb"
        alias f="find -name"
        cd $IMPALA_HOME
      }
    '';
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "z"];
      theme = "blinks";
    };
  };
  home.file = {
    ".tmux.conf".text = ''
      set-window-option -g mode-keys vi
      set-option -g default-command zsh
      set -sg escape-time 0
      bind-key -n M-s copy-mode \; send-key ?
      bind -n S-Pageup copy-mode -u
      bind -n S-Pagedown copy-mode -u
    '';
    "scripts/shell.sh".text = ''
      export USER="''${USER-$(id -un)}"
      export NIX_PATH=nixpkgs=/home/''$USER/.nix-defexpr/channels/nixpkgs:nixos_stable=/home/''$USER/.nix-defexpr/channels/nixos_stable
      . ~/.nix-profile/etc/profile.d/nix.sh
      eval $(ssh-agent)
      LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive ${pkgs.tmux}/bin/tmux
    '';
  };
  programs.home-manager.enable = true;
  programs.home-manager.path = https://github.com/rycee/home-manager/archive/master.tar.gz;
}
