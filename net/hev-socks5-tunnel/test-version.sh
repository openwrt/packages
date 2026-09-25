#!/bin/sh

"$1" 2>&1 | grep "$2"
