FROM anapsix/alpine-java:8
MAINTAINER Jindřich Mynarz <mynarzjindrich@gmail.com>

RUN apk add --update wget ca-certificates bash

ENV STARDOG_VER=4.1.3 \
    STARDOG_HOME=/stardog

# Directory for data
RUN mkdir -p $STARDOG_HOME

COPY resources/stardog-${STARDOG_VER}.zip /
RUN unzip stardog-${STARDOG_VER}.zip && \
    rm stardog-${STARDOG_VER}.zip
COPY resources/stardog-license-key.bin $STARDOG_HOME
COPY resources/stardog.properties $STARDOG_HOME
COPY bin/*.sh $STARDOG_HOME-$STARDOG_VER/
ADD resources/setup/sparql/ $STARDOG_HOME-$STARDOG_VER/setup/sparql/

WORKDIR $STARDOG_HOME-$STARDOG_VER

RUN ["./seed.sh"] 

EXPOSE 5820

CMD ["./start.sh"]
