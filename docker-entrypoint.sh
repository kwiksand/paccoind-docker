#!/bin/bash

set -e
PACCOIN_DATA=/home/paccoin/.paccoin
CONFIG_FILE=paccoin.conf

if [ -z "$1" ] || [ "$1" == "paccoind" ] || [ "$(echo "$0" | cut -c1)" == "-" ]; then
  cmd=paccoind
  shift

  if [ ! -d $PACCOIN_DATA ]; then
    echo "$0: DATA DIR ($PACCOIN_DATA) not found, please create and add config.  exiting...."
    exit 1
  fi

  if [ ! -f $PACCOIN_DATA/$CONFIG_FILE ]; then
    echo "$0: paccoind config ($PACCOIN_DATA/$CONFIG_FILE) not found, please create.  exiting...."
    exit 1
  fi

  chmod 700 "$PACCOIN_DATA"
  chown -R paccoin "$PACCOIN_DATA"

  if [ -z "$1" ] || [ "$(echo "$1" | cut -c1)" == "-" ]; then
    echo "$0: assuming arguments for paccoind"

    set -- $cmd "$@" -datadir="$PACCOIN_DATA"
  else
    set -- $cmd -datadir="$PACCOIN_DATA"
  fi

  exec gosu paccoin "$@"
else
  echo "This entrypoint will only execute paccoind, paccoin-cli and paccoin-tx"
fi
