AC_PREREQ(2.60)
AC_INIT(libmpdclient, 2.16, musicpd-dev-team@lists.sourceforge.net)
AC_CONFIG_SRCDIR([src/connection.c])
AC_CONFIG_AUX_DIR(build)
AM_INIT_AUTOMAKE([foreign 1.11 dist-xz subdir-objects silent-rules])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AC_SUBST(MAJOR_VERSION,2)
AC_SUBST(MINOR_VERSION,16)
AC_SUBST(PATCH_VERSION,0)

LIBMPDCLIENT_LIBTOOL_VERSION=2:16:0
AC_SUBST(LIBMPDCLIENT_LIBTOOL_VERSION)

# Remove the check for c++ and fortran compiler
m4_defun([_LT_AC_LANG_CXX_CONFIG], [:])
m4_defun([_LT_AC_LANG_F77_CONFIG], [:])

dnl Check for programs
AC_PROG_CC_C99
AC_PROG_INSTALL

AC_PROG_LD
AM_CONDITIONAL(HAVE_GNU_LD, test x$with_gnu_ld = xyes)

AC_LIBTOOL_WIN32_DLL
AC_PROG_LIBTOOL


dnl
dnl initialize variables
dnl

set -- $CFLAGS


dnl
dnl OS specific defaults
dnl

AC_CANONICAL_HOST

case "$host_os" in
mingw32* | windows*)
	LIBS="$LIBS -lws2_32"
	;;
esac


dnl
dnl Check for libraries
dnl

AC_SEARCH_LIBS([socket], [network socket])


dnl
dnl build options
dnl

AC_ARG_ENABLE(documentation,
	AS_HELP_STRING([--disable-documentation],
		[Disable API doc generation @<:@default=enabled@:>@]),,
	[enable_documentation=yes])

if test "x$enable_documentation" = xyes; then
	AC_PATH_PROG(DOXYGEN, doxygen)
	if test x$DOXYGEN = x; then
		AC_MSG_ERROR([doxygen not found])
	fi

	AC_SUBST(DOXYGEN)
fi
AM_CONDITIONAL(DOXYGEN, test x$enable_documentation = xyes)

AC_ARG_ENABLE(tcp,
	AS_HELP_STRING([--disable-tcp],
		[Disable TCP support @<:@default=enabled@:>@]),,
	[enable_tcp=yes])
if test "x$enable_tcp" = xyes; then
	AC_DEFINE([ENABLE_TCP], 1, [Define to enable TCP support])
	AC_SEARCH_LIBS([gethostbyname], [nsl])
	AC_CHECK_FUNCS([getaddrinfo])
	AC_CHECK_FUNCS([strndup])
fi

AC_ARG_ENABLE(werror,
	AS_HELP_STRING([--enable-werror],
		[Treat warnings as errors @<:@default=disabled@:>@]),
	enable_werror=no)

if test "x$enable_werror" = xyes; then
	AM_CFLAGS="$AM_CFLAGS -Werror -pedantic-errors"
fi

AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[Enable debugging @<:@default=disabled@:>@]),
	enable_debug=no)

if test "x$enable_debug" = xno; then
	AM_CFLAGS="$AM_CFLAGS -DNDEBUG"
fi


dnl
dnl CFLAGS
dnl

AC_SUBST(AM_CFLAGS)
AC_SUBST(AM_CPPFLAGS)

WANTED_CFLAGS="-Wall -W -Wextra -Wno-deprecated-declarations -Wmissing-prototypes -Wshadow -Wpointer-arith -Wstrict-prototypes -Wcast-qual -Wwrite-strings"
for flag in $WANTED_CFLAGS ; do
	AX_CHECK_COMPILER_FLAGS([$flag], [CFLAGS="$CFLAGS $flag"],)
done

dnl
dnl Compile-time options
dnl

AC_ARG_WITH([default-socket],
	AC_HELP_STRING([--with-default-socket=PATH],
		[default path of the socket file @<:@/var/run/mpd/socket@:>@]),,
	[with_default_socket=auto])

if test x$with_default_socket = xauto; then
	case "$host_os" in
	mingw32* | windows*)
		# no UNIX domain sockets on WIN32
		with_default_socket=no
		;;
	*)
		with_default_socket=/var/run/mpd/socket
		;;
	esac
fi

if test x$with_default_socket != xno; then
	AC_DEFINE_UNQUOTED([DEFAULT_SOCKET], ["$with_default_socket"],
		[Default UNIX socket path])
fi

AC_ARG_WITH([default-host],
	AC_HELP_STRING([--with-default-host=ARG],
		[default MPD host @<:@localhost@:>@]),,
	[with_default_host=localhost])
AC_DEFINE_UNQUOTED([DEFAULT_HOST], ["$with_default_host"], [Default MPD host])

AC_ARG_WITH([default-port],
	AC_HELP_STRING([--with-default-port=ARG],
		[default MPD port @<:@6600@:>@]),,
	[with_default_port=6600])
AC_DEFINE_UNQUOTED([DEFAULT_PORT], [$with_default_port], [Default MPD port])


dnl
dnl Done
dnl

AC_OUTPUT([Makefile include/mpd/version.h libmpdclient.pc doc/doxygen.conf])
