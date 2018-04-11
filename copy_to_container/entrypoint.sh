sudo service postgresql start
sudo service ssh start
# Workaround overlay filesystem: KUDU-1419.
if [[ "$(df -Th | grep "/$" | awk '{print $2}')" -eq "overlay" ]]; then
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
  git remote add gerrit "http://$GITHUB_USERNAME@gerrit.cloudera.org:8080/a/Impala"
fi
if [ "${GIT_USER_NAME+x}" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ "${GIT_EMAIL+x}" ]; then
  git config --global user.email "$GIT_EMAIL"
fi
"$@"
