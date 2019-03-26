ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = foreign 1.11 dist-xz subdir-objects

mpdincludedir = $(includedir)/mpd
mpdinclude_HEADERS = \
	include/mpd/async.h \
	include/mpd/audio_format.h \
	include/mpd/client.h \
	include/mpd/capabilities.h \
	include/mpd/compiler.h \
	include/mpd/connection.h \
	include/mpd/database.h \
	include/mpd/directory.h \
	include/mpd/entity.h \
	include/mpd/error.h \
	include/mpd/idle.h \
	include/mpd/list.h \
	include/mpd/mixer.h \
	include/mpd/mount.h \
	include/mpd/parser.h \
	include/mpd/password.h \
	include/mpd/player.h \
	include/mpd/playlist.h \
	include/mpd/protocol.h \
	include/mpd/queue.h \
	include/mpd/recv.h \
	include/mpd/response.h \
	include/mpd/send.h \
	include/mpd/status.h \
	include/mpd/stats.h \
	include/mpd/tag.h \
	include/mpd/output.h \
	include/mpd/pair.h \
	include/mpd/search.h \
	include/mpd/socket.h \
	include/mpd/song.h \
	include/mpd/sticker.h \
	include/mpd/settings.h \
	include/mpd/message.h \
	include/mpd/version.h

AM_CPPFLAGS += -I$(srcdir)/include -Iinclude

lib_LTLIBRARIES = src/libmpdclient.la

src_libmpdclient_la_SOURCES = \
	src/async.c src/iasync.h \
	src/audio_format.c \
	src/buffer.h \
	src/internal.h \
	src/ierror.c src/ierror.h \
	src/resolver.c src/resolver.h \
	src/capabilities.c \
	src/connection.c \
	src/database.c \
	src/directory.c \
	src/rdirectory.c \
	src/error.c \
	src/fd_util.c src/fd_util.h \
	src/output.c \
	src/coutput.c \
	src/entity.c \
	src/idle.c \
	src/iso8601.h \
	src/iso8601.c \
	src/kvlist.c \
	src/list.c \
	src/mixer.c \
	src/mount.c \
	src/cmount.c \
	src/parser.c \
	src/password.c \
	src/player.c \
	src/playlist.c \
	src/rplaylist.c \
	src/cplaylist.c \
	src/queue.c \
	src/quote.c src/quote.h \
	src/recv.c \
	src/response.c \
	src/run.c src/run.h \
	src/search.c \
	src/send.c src/isend.h \
	src/socket.c src/socket.h \
	src/song.c \
	src/status.c \
	src/cstatus.c \
	src/stats.c \
	src/cstats.c \
	src/sync.c src/sync.h \
	src/tag.c \
	src/sticker.c \
	src/settings.c \
	src/message.c \
	src/cmessage.c \
	src/uri.h

src_libmpdclient_la_LDFLAGS = -version-info @LIBMPDCLIENT_LIBTOOL_VERSION@ \
	-no-undefined

if HAVE_GNU_LD
src_libmpdclient_la_LDFLAGS += -Wl,--version-script=$(srcdir)/libmpdclient.ld
endif

#
# Installation
#

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = libmpdclient.pc

#
# Distribution
#

EXTRA_DIST = \
	libmpdclient.ld \
	libmpdclient.pc.in 
