#!/bin/sh

[ "$1" = "openblas" ] || exit 0

ls /usr/lib/libopenblas*.so* | grep -q "libopenblas"
