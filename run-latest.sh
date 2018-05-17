# Start the container in the backgroud
# Use 80% cpu/memory
# Bind x11 sockets
# Inherit git configs
# link .ssh folder
CONTAINER=$(docker run -d -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY --cpus="$(awk '{printf "%.1f", $1 * 0.8}' <<< $(nproc))" -m="$(awk '/MemAvailable:/ {printf "%d", $2 * 0.8}' /proc/meminfo)k" -e BUILD_FARM -e GITHUB_USERNAME impala:latest sleep infinity)
# allow the container to use host X server.
xhost +local:$(docker inspect --format='{{ .Config.Hostname }}' $CONTAINER)
docker exec -it -e TERM $CONTAINER bash scripts/shell.sh

