with import <nixpkgs> {};

stdenv.mkDerivation {

  name = "gui-docker-env";

  buildInputs = [xorg.xhost docker systemd git stdenv];

}
