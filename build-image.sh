#! /usr/bin/env nix-shell
#! nix-shell -i bash -p stdenv git docker systemd
IMPALA_REPO="${IMPALA_REPO:-https://git-wip-us.apache.org/repos/asf/impala.git}"
REMOTE_MASTER="$(git ls-remote "$IMPALA_REPO" | grep refs/heads/master | awk '{print $1}')"
GIT_REV="${IMPALA_REV:-$REMOTE_MASTER}"
IMAGE_NAME="${IMAGE_NAME:-impala:$GIT_REV}"
docker build -t "$IMAGE_NAME" --build-arg TZ="$(timedatectl | grep -oP "Time zone: \K[^\(]*")" --build-arg REPO="$IMPALA_REPO" --build-arg REV="$GIT_REV" .
if [[ "$GIT_REV" == "$REMOTE_MASTER" ]]; then
  docker tag "$IMAGE_NAME" impala:latest
fi
