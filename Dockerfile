FROM alpine
MAINTAINER Jindřich Mynarz <mynarzjindrich@gmail.com>

# Based on <https://github.com/Dockerizing/Stardog>

# https://github.com/rhuss/docker-java-jolokia/blob/master/base/alpine/jre/8/Dockerfile
ENV JRE=jre1.8.0_60 \
    JAVA_HOME=/opt/jre

COPY lib/ /tmp/lib

# That's an 1.8.0_60 JRE from OpenJDK.net
# Courtesy to https://github.com/frol/docker-alpine-oraclejdk8 from where the setup of glibc is borrowed
RUN apk add --update wget ca-certificates bash && \
    cd /tmp && \
    apk add --allow-untrusted /tmp/lib/glibc-2.21-r2.apk /tmp/lib/glibc-bin-2.21-r2.apk && \
    /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    mkdir /opt && \
    wget http://www.java.net/download/jdk8u60/archive/b18/binaries/jre-8u60-ea-bin-b18-linux-x64-02_jun_2015.tar.gz -O /tmp/${JRE}.tgz && \
    cd /opt && tar zxvf /tmp/${JRE}.tgz && \
    ln -s /opt/${JRE} /opt/jre && \
    ln -s /opt/jre/bin/java /usr/bin/java && \
    apk del wget ca-certificates && \
    apk add --update unzip &&\
    rm -rf /tmp/* /var/cache/apk/*

ENV STARDOG_VER=4.1.3 \
    STARDOG_HOME=/stardog

WORKDIR /

# Define mountable directories.
VOLUME ["/stardog"]

COPY resources/stardog-${STARDOG_VER}.zip /
RUN unzip stardog-${STARDOG_VER}.zip -d / && rm stardog-${STARDOG_VER}.zip
COPY resources/stardog-license-key.bin /stardog-$STARDOG_VER/
COPY resources/stardog.properties /

WORKDIR /stardog-${STARDOG_VER}

EXPOSE 5820

CMD rm /stardog/system.lock || true && \
    cp /stardog-$STARDOG_VER/stardog-license-key.bin $STARDOG_HOME && \
    ./bin/stardog-admin server start --disable-security --config /stardog.properties && \
    sleep 1 && \
    (tail -f $STARDOG_HOME/stardog.log &) && \
    IS_TERMINATED=false && \
    trap "IS_TERMINATED=true" SIGTERM SIGINT && \
    while ! $IS_TERMINATED; do sleep 1; done  && \
   ./bin/stardog-admin server stop && \
