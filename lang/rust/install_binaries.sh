#!/usr/bin/env bash
#
# Rust Langauge Host Installer
#
TMP_DIR=$1
RUST_INSTALL_FILE_NAME=$2
CARGO_HOME=$3

tar -C $TMP_DIR -xvJf $RUST_INSTALL_FILE_NAME

cd $TMP_DIR && \
   find -iname "*.xz" -exec tar -v -x -J -f {} ";" && \
   find ./* -type f -name install.sh -execdir sh {} --prefix=$CARGO_HOME --disable-ldconfig \;
