FROM centos:7
MAINTAINER Nimrod Shneor https://github.com/nimrodshn/manageiq-dev-container

# Set ENV, LANG only needed if building with docker-1.8
ENV LANG en_US.UTF-8
ENV TERM xterm
ENV APP_ROOT /manageiq
ARG APPLIANCE_PG_DATA=/var/opt/rh/rh-postgresql95/lib/pgsql/data

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install centos-release-scl-rh && \
    yum -y install --setopt=tsflags=nodocs \
                   git                                \
                   memcached                          \
                   rh-postgresql95-postgresql-libs    \
                   rh-postgresql95-postgresql-server  \
                   rh-postgresql95-postgresql-devel   \
                   bzip2                              \
                   libffi-devel                       \
                   readline-devel                     \
                   libxml2-devel                      \
                   libxslt-devel                      \
                   patch                              \
                   make                               \
                   sqlite-devel                       \
                   gcc-c++                            \
                   libcurl-devel                      \
                   openssl-devel                      \
                   readline-devel                     \
                   libyaml-devel                      \
                   sqlite-devel                       \
                   gdbm-devel                         \
                   automake                           \
                   net-tools                          \
                   nodejs                             \
                   cmake                              \
                   which                              \
                   npm                                \
                   &&                                 \
    
    yum clean all

# Add persistent data volume for postgresql
VOLUME [ "${APPLIANCE_PG_DATA}" ]

# Download chruby and chruby-install, install, setup environment, clean all
RUN curl -sL https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz | tar xz && \
    cd chruby-0.3.9 && \
    make install && \
    scripts/setup.sh && \
    echo "gem: --no-ri --no-rdoc --no-document" > ~/.gemrc && \
    echo "source /usr/local/share/chruby/chruby.sh" >> ~/.bashrc && \
    curl -sL https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz | tar xz && \
    cd ruby-install-0.6.0 && \
    make install && \
    ruby-install ruby 2.3.1 -- --disable-install-doc && \
    echo "chruby ruby-2.3.1" >> ~/.bash_profile && \
    rm -rf /chruby-* && \
    rm -rf /usr/local/src/* && \
    yum clean all

## Setup environment

RUN echo "# Description: Sets the environment for scripts and console users" >> /etc/default/evm && \
    echo "[[ -s /etc/default/evm_dev ]] && source /etc/default/evm_dev" >> /etc/default/evm && \
    echo "export PATH=\$PATH:/opt/rubies/ruby-2.3.1/bin" >> /etc/default/evm && \
    echo "export CONTAINER=true" >> /etc/default/evm && \
    echo "export APPLIANCE_PG_DATA=${APPLIANCE_PG_DATA}" >> /etc/default/evm_dev && \
    echo "[[ -s /opt/rh/rh-postgresql95/enable ]] && source /opt/rh/rh-postgresql95/enable" >> /etc/default/evm_dev && \
    mkdir ${APP_ROOT}

## Copy entrypoint and run scripts
COPY docker-assets/container-entrypoint-dev /usr/bin
COPY docker-assets/run-miq-dev /usr/bin

## Git clone manageiq
RUN git clone --depth 1 https://github.com/ManageIQ/manageiq ${APP_ROOT}
ADD . ${APP_ROOT}

## Change WORKDIR to clone dir
WORKDIR ${APP_ROOT}

## Build/install gems
RUN source /etc/default/evm && \
    export RAILS_USE_MEMORY_STORE="true" && \
    npm install gulp bower yarn -g && \
    gem install bundler && \
    bin/setup --no-db --no-tests && \
    # Cleanup install artifacts
    npm cache clean && \
    bower --allow-root cache clean && \
    find ${RUBY_GEMS_ROOT}/gems/ -name .git | xargs rm -rvf && \
    find ${RUBY_GEMS_ROOT}/gems/ | grep "\.s\?o$" | xargs rm -rvf && \
    rm -rvf ${RUBY_GEMS_ROOT}/gems/rugged-*/vendor/libgit2/build && \
    rm -rvf ${RUBY_GEMS_ROOT}/cache/* && \
    rm -rvf /root/.bundle/cache && \
    rm -rvf ${APP_ROOT}/tmp/cache/assets

## Expose required container ports
EXPOSE 3000

ENTRYPOINT [ "container-entrypoint-dev" ]
CMD [ "run-miq-dev" ]
