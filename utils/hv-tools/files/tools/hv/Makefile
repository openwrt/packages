# SPDX-License-Identifier: GPL-2.0
# Makefile for Hyper-V tools

sbindir ?= /usr/sbin
libexecdir ?= /usr/libexec
sharedstatedir ?= /var/lib

# Do not use make's built-in rules
MAKEFLAGS += -r

override CFLAGS += -O2 -Wall -g -D_GNU_SOURCE -I$(OUTPUT)include

ALL_TARGETS := hv_kvp_daemon hv_vss_daemon hv_fcopy_daemon
ALL_PROGRAMS := $(patsubst %,$(OUTPUT)%,$(ALL_TARGETS))

all: $(ALL_PROGRAMS)

# Define object files for each daemon
hv_kvp_daemon.o: hv_kvp_daemon.c
	$(CC) $(CFLAGS) -c $< -o $(OUTPUT)$@

hv_vss_daemon.o: hv_vss_daemon.c
	$(CC) $(CFLAGS) -c $< -o $(OUTPUT)$@

hv_fcopy_daemon.o: hv_fcopy_daemon.c
	$(CC) $(CFLAGS) -c $< -o $(OUTPUT)$@

$(OUTPUT)hv_kvp_daemon: $(OUTPUT)hv_kvp_daemon.o
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

$(OUTPUT)hv_vss_daemon: $(OUTPUT)hv_vss_daemon.o
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

$(OUTPUT)hv_fcopy_daemon: $(OUTPUT)hv_fcopy_daemon.o
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@

clean:
	rm -f $(ALL_PROGRAMS)
	find $(or $(OUTPUT),.) -name '*.o' -delete -o -name '\.*.d' -delete

install: $(ALL_PROGRAMS)
	install -d -m 755 $(DESTDIR)$(sbindir); \
	install -d -m 755 $(DESTDIR)$(libexecdir)/hypervkvpd; \
	install -d -m 755 $(DESTDIR)$(sharedstatedir); \
	for program in $(ALL_PROGRAMS); do \
		install $$program -m 755 $(DESTDIR)$(sbindir);	\
	done; \
	install -m 755 lsvmbus $(DESTDIR)$(sbindir); \
	for script in $(ALL_SCRIPTS); do \
		install $$script -m 755 $(DESTDIR)$(libexecdir)/hypervkvpd/$${script%.sh}; \
	done

FORCE:

.PHONY: all install clean FORCE prepare
