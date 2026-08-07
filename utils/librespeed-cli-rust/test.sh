#!/bin/sh
set -e

# A report header, which needs no network.
librespeed-cli --csv-header | grep -q '^Timestamp,Server Name,Address,Ping,Jitter,Download,Upload,Share,IP$'

# Exercise the async runtime against a loopback server the binary starts
# itself, so no external network is needed. This is deliberately part of the
# package test: tokio's reactor deadlocks on powerpc_8548, so running it
# across the whole test matrix shows whether that is specific to that target.
nettest --self mt
