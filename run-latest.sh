#! /usr/bin/env nix-shell
#! nix-shell -i bash -p xorg.xhost docker stdenv
if [ ${DISTCC_CONFIG:+x} ]; then
    DISTCC_ARGS=("-v" "$DISTCC_CONFIG:/home/impdev/scripts/distcc.sh:ro")
fi
# start the container in the backgroud
# use 85% cpu/memory
# bind x11 sockets
# inherit git configs
CONTAINER=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY --cpus="$(awk '{printf "%.1f", $1 * 0.85}' <<< $(nproc))" -m="$(awk '/MemAvailable:/ {printf "%d", $2 * 0.85}' /proc/meminfo)k" "${DISTCC_ARGS[@]}" -e GITHUB_USERNAME -e GIT_USER_NAME="$(git config --global user.name)" -e GIT_EMAIL="$(git config --global user.email)" impala:latest sleep infinity)
echo $CONTAINER
# allow the container to use host X server
xhost +local:$(docker inspect --format='{{ .Config.Hostname }}' $CONTAINER)

