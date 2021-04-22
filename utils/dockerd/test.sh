#!/bin/sh

set -e

opkg install docker dockerd

#PKG_NAME="${1}"
PKG_VERSION="${2%-[0-9]*}"
#PKG_RELEASE="${2#${PKG_VERSION}-}"

docker version | grep -B2 "${PKG_VERSION}"

docker run --name docker-test --init --publish 80:80 --rm --detach nginx
wget http://localhost -O - | grep "<title>Welcome to nginx!</title>"
docker stop docker-test
