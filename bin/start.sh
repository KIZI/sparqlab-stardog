#!/bin/bash

set -e

IS_TERMINATED=false

_term() {
  bin/stardog-admin server stop
  sleep 1
  echo "Stardog was stopped!"
  IS_TERMINATED=true 
}

trap _term SIGTERM SIGINT

rm $STARDOG_HOME/system.lock || true
bin/stardog-admin server start --disable-security --config /stardog.properties

while ! $IS_TERMINATED; do sleep 5; done
