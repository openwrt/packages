# gnome-compiler-flags.m4
#
# serial 4
#

dnl GNOME_COMPILE_WARNINGS
dnl Turn on many useful compiler warnings and substitute the result into
dnl WARN_CFLAGS
dnl For now, only works on GCC
dnl Pass the default value of the --enable-compile-warnings configure option as
dnl the first argument to the macro, defaulting to 'yes'.
dnl Additional warning/error flags can be passed as an optional second argument.
dnl
dnl For example: GNOME_COMPILE_WARNINGS([maximum],[-Werror=some-flag -Wfoobar])
AU_DEFUN([GNOME_COMPILE_WARNINGS],[
    dnl ******************************
    dnl More compiler warnings
    dnl ******************************

    AC_ARG_ENABLE(compile-warnings, 
                  AS_HELP_STRING([--enable-compile-warnings=@<:@no/minimum/yes/maximum/error@:>@],
                                 [Turn on compiler warnings]),,
                  [enable_compile_warnings="m4_default([$1],[yes])"])

    if test "x$GCC" != xyes; then
	enable_compile_warnings=no
    fi

    warning_flags=
    realsave_CFLAGS="$CFLAGS"

    dnl These are warning flags that aren't marked as fatal.  Can be
    dnl overridden on a per-project basis with -Wno-foo.
    base_warn_flags=" \
        -Wall \
        -Wstrict-prototypes \
        -Wnested-externs \
    "

    dnl These compiler flags typically indicate very broken or suspicious
    dnl code.  Some of them such as implicit-function-declaration are
    dnl just not default because gcc compiles a lot of legacy code.
    dnl We choose to make this set into explicit errors.
    base_error_flags=" \
        -Werror=missing-prototypes \
        -Werror=implicit-function-declaration \
        -Werror=pointer-arith \
        -Werror=init-self \
        -Werror=format-security \
        -Werror=format=2 \
        -Werror=missing-include-dirs \
        -Werror=return-type \
    "

    dnl Additional warning or error flags provided by the module author to
    dnl allow stricter standards to be imposed on a per-module basis.
    dnl The author can pass -W or -Werror flags here as they see fit.
    additional_flags="m4_default([$2],[])"

    case "$enable_compile_warnings" in
    no)
        warning_flags="-w"
        ;;
    minimum)
        warning_flags="-Wall"
        ;;
    yes|maximum|error)
        warning_flags="$base_warn_flags $base_error_flags $additional_flags"
        ;;
    *)
        AC_MSG_ERROR(Unknown argument '$enable_compile_warnings' to --enable-compile-warnings)
        ;;
    esac

    if test "$enable_compile_warnings" = "error" ; then
        warning_flags="$warning_flags -Werror"
    fi

    dnl Check whether GCC supports the warning options
    for option in $warning_flags; do
	save_CFLAGS="$CFLAGS"
	CFLAGS="$CFLAGS $option"
	AC_MSG_CHECKING([whether gcc understands $option])
	AC_TRY_COMPILE([], [],
	    has_option=yes,
	    has_option=no,)
	CFLAGS="$save_CFLAGS"
	AC_MSG_RESULT([$has_option])
	if test $has_option = yes; then
	    tested_warning_flags="$tested_warning_flags $option"
	fi
	unset has_option
	unset save_CFLAGS
    done
    unset option
    CFLAGS="$realsave_CFLAGS"
    AC_MSG_CHECKING(what warning flags to pass to the C compiler)
    AC_MSG_RESULT($tested_warning_flags)

    AC_ARG_ENABLE(iso-c,
                  AS_HELP_STRING([--enable-iso-c],
                                 [Try to warn if code is not ISO C ]),,
                  [enable_iso_c=no])

    AC_MSG_CHECKING(what language compliance flags to pass to the C compiler)
    complCFLAGS=
    if test "x$enable_iso_c" != "xno"; then
	if test "x$GCC" = "xyes"; then
	case " $CFLAGS " in
	    *[\ \	]-ansi[\ \	]*) ;;
	    *) complCFLAGS="$complCFLAGS -ansi" ;;
	esac
	case " $CFLAGS " in
	    *[\ \	]-pedantic[\ \	]*) ;;
	    *) complCFLAGS="$complCFLAGS -pedantic" ;;
	esac
	fi
    fi
    AC_MSG_RESULT($complCFLAGS)

    WARN_CFLAGS="$tested_warning_flags $complCFLAGS"
    AC_SUBST(WARN_CFLAGS)
],
[[$0: This macro is deprecated. You should use AX_COMPILER_FLAGS instead and
eliminate use of --enable-iso-c.
See: http://www.gnu.org/software/autoconf-archive/ax_compiler_flags.html#ax_compiler_flags]])

dnl For C++, do basically the same thing.

AU_DEFUN([GNOME_CXX_WARNINGS],[
  AC_ARG_ENABLE(cxx-warnings,
                AS_HELP_STRING([--enable-cxx-warnings=@<:@no/minimum/yes@:>@]
                               [Turn on compiler warnings.]),,
                [enable_cxx_warnings="m4_default([$1],[minimum])"])

  AC_MSG_CHECKING(what warning flags to pass to the C++ compiler)
  warnCXXFLAGS=
  if test "x$GXX" != xyes; then
    enable_cxx_warnings=no
  fi
  if test "x$enable_cxx_warnings" != "xno"; then
    if test "x$GXX" = "xyes"; then
      case " $CXXFLAGS " in
      *[\ \	]-Wall[\ \	]*) ;;
      *) warnCXXFLAGS="-Wall -Wno-unused" ;;
      esac

      ## -W is not all that useful.  And it cannot be controlled
      ## with individual -Wno-xxx flags, unlike -Wall
      if test "x$enable_cxx_warnings" = "xyes"; then
	warnCXXFLAGS="$warnCXXFLAGS -Wshadow -Woverloaded-virtual"
      fi
    fi
  fi
  AC_MSG_RESULT($warnCXXFLAGS)

   AC_ARG_ENABLE(iso-cxx,
                 AS_HELP_STRING([--enable-iso-cxx],
                                [Try to warn if code is not ISO C++ ]),,
                 [enable_iso_cxx=no])

   AC_MSG_CHECKING(what language compliance flags to pass to the C++ compiler)
   complCXXFLAGS=
   if test "x$enable_iso_cxx" != "xno"; then
     if test "x$GXX" = "xyes"; then
      case " $CXXFLAGS " in
      *[\ \	]-ansi[\ \	]*) ;;
      *) complCXXFLAGS="$complCXXFLAGS -ansi" ;;
      esac

      case " $CXXFLAGS " in
      *[\ \	]-pedantic[\ \	]*) ;;
      *) complCXXFLAGS="$complCXXFLAGS -pedantic" ;;
      esac
     fi
   fi
  AC_MSG_RESULT($complCXXFLAGS)

  WARN_CXXFLAGS="$CXXFLAGS $warnCXXFLAGS $complCXXFLAGS"
  AC_SUBST(WARN_CXXFLAGS)
],
[[$0: This macro is deprecated. You should use AX_COMPILER_FLAGS instead and
eliminate use of --enable-iso-cxx.
See: http://www.gnu.org/software/autoconf-archive/ax_compiler_flags.html#ax_compiler_flags]])
