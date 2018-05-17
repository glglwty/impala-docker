sudo service postgresql start
sudo service ssh start
# Workaround overlay filesystem: KUDU-1419.
if [[ "$(df -Th | grep "/$" | awk '{print $2}')" == "overlay" ]]; then
  for x in "$IMPALA_HOME/testdata/cluster/cdh*/node-*/var/lib/kudu/*/wal"; do
    mv "$x" "$x-orig"
    mkdir "$x"
    mv "$x-orig/*" "$x"
    rmdir "$x-orig"
  done
fi
# optionally set git remotes
if [ "${GITHUB_USERNAME+x}" ]; then
  cd "$IMPALA_HOME"
  git remote add "$GITHUB_USERNAME" "https://github.com/$GITHUB_USERNAME/impala.git"
  git remote add gerrit "ssh://glglwty@gerrit.cloudera.org:29418/Impala-ASF"
fi
# optional set distcc toolchains
if [ "${BUILD_FARM+x}" ]; then
  sudo ln -s $IMPALA_HOME/toolchain /opt/Impala-Toolchain
fi
# workaround hdfs networking issues
NEW_HOSTS=$(mktemp)
cp /etc/hosts $NEW_HOSTS
sed -i "/.*$(hostname).*/d" $NEW_HOSTS
echo "127.0.0.1 $(hostname)" >> $NEW_HOSTS
# Prevent kudu start script from attempting to ntp-wait
echo "0.0.0.1 pool.ntp.org" >> $NEW_HOSTS
sudo cp $NEW_HOSTS /etc/hosts
"$@"