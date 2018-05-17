curl https://nixos.org/nix/install | sh
. ~/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://nixos.org/channels/nixos-18.03 nixos_stable
nix-channel --update
HM_PATH=https://github.com/rycee/home-manager/archive/master.tar.gz
export NIX_PATH=nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs:nixos_stable=$HOME/.nix-defexpr/channels/nixos_stable
nix-shell --max-jobs $(nproc) $HM_PATH -A install

