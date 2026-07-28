#!/bin/sh
autoconf --version | grep $2 && \
autoheader --version | grep $2 && \
autom4te --version | grep $2 && \
autoreconf --version | grep $2 && \
autoscan --version | grep $2 && \
autoupdate --version | grep $2 && \
ifnames --version | grep $2
