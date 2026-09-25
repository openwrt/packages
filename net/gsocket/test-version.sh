#!/bin/sh

gs-netcat -h 2>&1  | grep "$2"
