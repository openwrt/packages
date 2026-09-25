#!/bin/sh

[ "$1" = "lpac" ] && /usr/bin/lpac --version | grep -F '"code":0'
