# gnome-common.m4
#
# serial 3
# 

AU_DEFUN([GNOME_DEBUG_CHECK],
[
	AX_CHECK_ENABLE_DEBUG([no],[GNOME_ENABLE_DEBUG])
],
[[$0: This macro is deprecated. You should use AX_CHECK_ENABLE_DEBUG instead and
replace uses of GNOME_ENABLE_DEBUG with ENABLE_DEBUG.
See: http://www.gnu.org/software/autoconf-archive/ax_check_enable_debug.html#ax_check_enable_debug]])

dnl GNOME_MAINTAINER_MODE_DEFINES ()
dnl define DISABLE_DEPRECATED
dnl
AU_DEFUN([GNOME_MAINTAINER_MODE_DEFINES],
[
	AC_REQUIRE([AM_MAINTAINER_MODE])

	DISABLE_DEPRECATED=""
	if test $USE_MAINTAINER_MODE = yes; then
	        DOMAINS="GCONF BONOBO BONOBO_UI GNOME LIBGLADE GNOME_VFS WNCK LIBSOUP"
	        for DOMAIN in $DOMAINS; do
	               DISABLE_DEPRECATED="$DISABLE_DEPRECATED -D${DOMAIN}_DISABLE_DEPRECATED -D${DOMAIN}_DISABLE_SINGLE_INCLUDES"
	        done
	fi

	AC_SUBST(DISABLE_DEPRECATED)
],
[[$0: This macro is deprecated. All of the modules it disables deprecations for
are obsolete. Remove it and all uses of DISABLE_DEPRECATED.]])
