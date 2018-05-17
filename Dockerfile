FROM ubuntu:16.04
# Add sudo user
RUN adduser --disabled-password --gecos '' impdev
RUN apt-get update && apt-get -y install sudo curl bzip2 git
RUN echo "impdev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "impdev:impdev" | chpasswd
# Set timezone 
ARG TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
USER impdev
WORKDIR /home/impdev
COPY --chown=impdev copy_to_container/ ./
RUN USER=impdev bash scripts/setup_nix.sh
ENV IMPALA_HOME /home/impdev/projects/impala
RUN mkdir -p ${IMPALA_HOME}
ARG REPO
ARG REV
RUN git clone $REPO ${IMPALA_HOME}
RUN git --git-dir=${IMPALA_HOME}/.git --work-tree=${IMPALA_HOME} checkout $REV
# Remove ntpupdate from bootstrap scripts
RUN sed -i '/sudo ntpdate us.pool.ntp.org/d' ${IMPALA_HOME}/bin/bootstrap_system.sh
RUN bash -c ". ${IMPALA_HOME}/bin/bootstrap_system.sh && ${IMPALA_HOME}/buildall.sh -ninja -notests -format -testdata"
RUN git --git-dir=${IMPALA_HOME}/.git --work-tree=${IMPALA_HOME} checkout .
# setup commit message hook
RUN curl -o $IMPALA_HOME/.git/hooks/commit-message http://gerrit.cloudera.org:8080/tools/hooks/commit-msg
RUN chmod +x $IMPALA_HOME/.git/hooks/commit-message
ENTRYPOINT ["bash", "scripts/entrypoint.sh"]
CMD ["bash", "scripts/shell.sh"]
