#!/bin/sh

netdata -version 2>&1 | grep "$2"
