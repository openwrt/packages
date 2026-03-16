#!/bin/sh

/etc/init.d/pbr version 2>&1 | grep "$2"
