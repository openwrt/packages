#!/bin/sh

xkcp_client -v 2>&1 | grep -F "$2" && \
xkcp_server -v 2>&1 | grep -F "$2"
