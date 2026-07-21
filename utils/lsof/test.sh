#!/bin/sh

lsof -v 2>&1 | grep "$2"
