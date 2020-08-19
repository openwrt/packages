#
# Copyright (C) 2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# Based on original Makefile
# Copyright (C) 2011 David Kuehling <dvdkhlng TA gmx TOD de>
#


include $(TOPDIR)/rules.mk

PKG_NAME:=swig
PKG_VERSION:=4.0.2
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/swig
PKG_HASH:=d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/swig
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Simplified Wrapper and Interface Generator
  URL:=http://www.swig.org
  DEPENDS:=+swig/host
endef

define Package/swig/description
SWIG is a software development tool that connects programs written in C and
C++ with a variety of high-level programming languages. SWIG is used with
different types of target languages including common scripting languages such
as Perl, PHP, Python, Tcl and Ruby.

You don't need to enable this package to build packages that rely on SWIG.
Instead just add '+swig/host' to the PKG_BUILD_DEPENDS line of your
package.
endef

##
## Compile for the host
##

HOST_CONFIGURE_ARGS += --without-pcre

define Host/Configure
	$(call Host/Configure/Default)
endef

define Host/Compile
	$(call Host/Compile/Default)
endef

define Host/Install
	$(call Host/Install/Default)
endef

##
## Compile for the target
##

# nothing to target-compile; everything done during host-compile step
define Package/swig/compile
endef

define Package/swig/install
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,swig))
