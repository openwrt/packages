ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = foreign 1.11 dist-xz subdir-objects

bin_PROGRAMS = src/mpc

src_mpc_SOURCES = \
	src/main.c src/mpc.h \
	src/list.c src/list.h \
	src/password.c src/password.h \
	src/status.c src/status.h \
	src/args.c src/args.h \
	src/format.c src/format.h \
	src/song_format.c src/song_format.h \
	src/util.c src/util.h \
	src/command.c src/command.h \
	src/queue.c src/queue.h \
	src/sticker.c src/sticker.h \
	src/tab.c src/tab.h \
	src/idle.c src/idle.h \
	src/message.c src/message.h \
	src/search.c src/search.h \
	src/output.c src/output.h \
	src/options.c src/options.h \
	src/path.c src/path.h \
	src/Compiler.h

if HAVE_ICONV
src_mpc_SOURCES += src/charset.c src/charset.h
endif

src_mpc_CPPFLAGS = $(AM_CPPFLAGS) $(ICONV_CFLAGS) $(LIBMPDCLIENT_CFLAGS)
src_mpc_LDADD = $(ICONV_LIBS) $(LIBMPDCLIENT_LIBS)

