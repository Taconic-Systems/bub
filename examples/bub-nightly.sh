#!/usr/bin/env bash

BUB_DATA_DIR=/var/lib/bub
mkdir -p $BUB_DATA_DIR

DEST=user@backuphost:archives

bub /etc $DEST
bub /var/lib $DEST
bub /var/www
