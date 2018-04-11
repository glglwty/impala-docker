FROM ubuntu:16.04
# Add sudo user
RUN adduser --disabled-password --gecos '' impdev
RUN apt-get update && apt-get -y install sudo git aria2 wget zsh
RUN echo "impdev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo "impdev:impdev" | chpasswd
# Set timezone 
ARG TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
USER impdev
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
RUN aria2c -o $IMPALA_HOME/.git/hooks/commit-msg http://gerrit.cloudera.org:8080/tools/hooks/commit-msg
RUN chmod +x $IMPALA_HOME/.git/hooks/commit-msg
# install IDEs, zsh
WORKDIR /home/impdev
RUN mkdir softwares
RUN aria2c https://download.jetbrains.com/cpp/CLion-2018.1.tar.gz -d softwares
RUN aria2c https://download.jetbrains.com/idea/ideaIC-2018.1.1-no-jdk.tar.gz -d softwares 
RUN ls softwares/*.tar.gz | xargs -P 2 -i tar xvf {} -C softwares
RUN rm softwares/*.tar.gz
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git .oh-my-zsh
COPY --chown=impdev copy_to_container/zshrc.zsh-template .zshrc
RUN mkdir scripts
COPY --chown=impdev copy_to_container/entrypoint.sh scripts/entrypoint.sh
COPY --chown=impdev copy_to_container/.CLion2018.1 ./.CLion2018.1
COPY --chown=impdev copy_to_container/.IdeaIC2018.1 ./.IdeaIC2018.1
# In a docker environment it would be nice to promt container name in your shell
COPY --chown=impdev copy_to_container/zsh_prompt_hostname.patch zsh_prompt_hostname.patch
RUN bash -c "cd .oh-my-zsh && git apply ~/zsh_prompt_hostname.patch && rm ~/zsh_prompt_hostname.patch"
COPY --chown=impdev copy_to_container/cmake_ninja_wrapper.py scripts/cmake_ninja_wrapper.py
ENTRYPOINT ["zsh", "scripts/entrypoint.sh"]
CMD ["zsh"]
