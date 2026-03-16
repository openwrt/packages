#!/bin/sh

"$1" -v 2>&1 | grep "$2"
