AC_PREREQ(2.60)
AC_INIT(mpc, 0.30, musicpd-dev-team@lists.sourceforge.net)
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR(src/main.c)
AM_INIT_AUTOMAKE([foreign 1.11 dist-xz subdir-objects])
AM_SILENT_RULES
AC_CONFIG_HEADERS(config.h)


dnl
dnl programs
dnl

AC_PROG_CC_C99
AC_PROG_INSTALL
AC_PROG_MAKE_SET
PKG_PROG_PKG_CONFIG


dnl
dnl declare variables
dnl

AC_SUBST(AM_CFLAGS)
AC_SUBST(AM_CPPFLAGS)


dnl
dnl OS specific defaults
dnl

case "$host" in
*-mingw32* | *-windows* | *-cygwin*)
	AM_CFLAGS="$AM_CFLAGS -mms-bitfields -fno-strict-aliasing"
	;;
esac

if test -z "$prefix" || test "x$prefix" = xNONE; then
	local_lib=
	local_include=

	# aren't autotools supposed to be smart enough to figure this out?
	# oh well, the git-core Makefile managed to do some of the work for us :)
	case "`uname -s | tr A-Z a-z`" in
	darwin*)
		local_lib='/sw/lib /opt/local/lib'
		local_include='/sw/include /opt/local/include'
		;;
	freebsd* | openbsd*)
		local_lib=/usr/local/lib
		local_include=/usr/local/include
		;;
	netbsd*)
		local_lib=/usr/pkg/lib
		local_include=/usr/pkg/include
		LDFLAGS="$LDFLAGS -Wl,-rpath,/usr/pkg/lib"
		;;
	esac

	for d in $local_lib; do
		if test -d "$d"; then
			LDFLAGS="$LDFLAGS -L$d"
			break
		fi
	done
	for d in $local_include; do
		if test -d "$d"; then
			CFLAGS="$CFLAGS -I$d"
			break
		fi
	done
fi


dnl
dnl libc features
dnl

PKG_CHECK_MODULES([LIBMPDCLIENT], [libmpdclient >= 2.9],,
	[AC_MSG_ERROR([libmpdclient 2.9 is required])])


dnl
dnl i18n / l10n (iconv)
dnl

AC_ARG_ENABLE(iconv,
	AS_HELP_STRING([--disable-iconv],
		[disable iconv support (default: enable)]),,
	[enable_iconv=yes])

if test x$enable_iconv = xyes; then
	AC_CHECK_FUNC(iconv,
		[ICONV_CFLAGS="" ICONV_LIBS=""],
		[AC_CHECK_LIB(intl, iconv,
			[ICONV_CFLAGS="" ICONV_LIBS="-lintl"],
			[enable_iconv=no])])
fi

if test x$enable_iconv = xyes; then
	AC_CHECK_HEADER([locale.h],, [enable_iconv=no])
	if test x$enable_iconv != xyes; then
		AC_MSG_WARN(locale.h not available - disabling iconv)
	fi
fi

if test x$enable_iconv = xyes; then
	AC_DEFINE(HAVE_ICONV, 1, [Define if iconv() support is enabled])
else
	ICONV_CPPFLAGS=""
	ICONV_LIBS=""
fi

AC_SUBST(ICONV_CPPFLAGS)
AC_SUBST(ICONV_LIBS)

AM_CONDITIONAL(HAVE_ICONV, test x$enable_iconv = xyes)


dnl
dnl CFLAGS
dnl

AX_APPEND_COMPILE_FLAGS([-Wall])
AX_APPEND_COMPILE_FLAGS([-Wextra])
AX_APPEND_COMPILE_FLAGS([-Wno-deprecated-declarations])
AX_APPEND_COMPILE_FLAGS([-Wmissing-prototypes])
AX_APPEND_COMPILE_FLAGS([-Wshadow])
AX_APPEND_COMPILE_FLAGS([-Wpointer-arith])
AX_APPEND_COMPILE_FLAGS([-Wstrict-prototypes])
AX_APPEND_COMPILE_FLAGS([-Wcast-qual])
AX_APPEND_COMPILE_FLAGS([-Wwrite-strings])


dnl
dnl build options
dnl

AC_ARG_ENABLE(werror,
	AS_HELP_STRING([--enable-werror],
		[Treat warnings as errors @<:@default=disabled@:>@]),,
	enable_werror=no)

if test "x$enable_werror" = xyes; then
	AM_CFLAGS="$AM_CFLAGS -Werror -pedantic-errors"
fi

AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[Enable debugging @<:@default=disabled@:>@]),,
	enable_debug=no)

if test "x$enable_debug" = xno; then
	AM_CPPFLAGS="$AM_CPPFLAGS -DNDEBUG"

	AX_APPEND_COMPILE_FLAGS([-ffunction-sections])
	AX_APPEND_COMPILE_FLAGS([-fdata-sections])
	AX_APPEND_COMPILE_FLAGS([-fvisibility=hidden])

	AX_APPEND_LINK_FLAGS([-Wl,--gc-sections])
fi

AC_ARG_ENABLE(test,
	AS_HELP_STRING([--enable-test],
		[build the test programs (default: disabled)]),,
	enable_test=no)

if test "x$enable_test" = xyes; then
	AM_PATH_CHECK(,, [AC_MSG_ERROR([check not found])])
fi

AM_CONDITIONAL(ENABLE_TEST, test "x$enable_test" = xyes)


dnl

AC_OUTPUT(Makefile)
