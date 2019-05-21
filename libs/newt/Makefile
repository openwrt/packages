#
# Copyright (C) 2006-2011 OpenWrt.org
# Copyright (C) 2011 SMBPhone Inc.
# Copyright (C) 2019 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=newt
PKG_VERSION:=0.52.20
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://releases.pagure.org/newt
PKG_HASH:=8d66ba6beffc3f786d4ccfee9d2b43d93484680ef8db9397a4fb70b5adbb6dbc

PKG_LICENSE:=LGPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:fedorahosted:newt
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/python/python3-package.mk

define Package/newt/Default
  TITLE:=Newt
  URL:=https://pagure.io/newt
endef

define Package/newt/Default/description
  Newt is a programming library for color text mode, widget based user
  interfaces.  Newt can be used to add stacked windows, entry widgets,
  checkboxes, radio buttons, labels, plain text fields, scrollbars, etc.,
  to text mode user interfaces.  Newt is based on the slang library.
endef

define Package/libnewt
$(call Package/newt/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE+= library
  DEPENDS:=+libslang2 $(INTL_DEPENDS)
endef

define Package/libnewt/description
$(call Package/newt/Default/description)
endef

define Package/whiptail
$(call Package/newt/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Display dialog boxes from shell scripts
  DEPENDS:=+libnewt +libpopt +libslang2
endef

define Package/whiptail/description
  A lightweight replacement for the dialog command (dialog boxes from shell
  scripts), based on libnewt.
endef

define Package/python3-newt
$(call Package/newt/Default)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE+= module for Python
  DEPENDS:=+libnewt +python3-light
  VARIANT:=python3
endef

define Package/python3-newt/description
$(call Package/newt/Default/description)

  This is the Newt module for Python 3.
endef

TARGET_CFLAGS+= $(FPIC)

CONFIGURE_ARGS+= \
	--enable-largefile \
	--with-python \
	--without-tcl \
	--without-gpm-support \
	--with-colorsfile=/etc/newt/palette

CONFIGURE_VARS+= PYTHONVERS="python$(PYTHON3_VERSION)"

MAKE_VARS+= PYTHON_CONFIG_PATH="$(STAGING_DIR)/usr/bin"

Build/Compile=$(call Build/Compile/Default,)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/newt.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnewt.{a,so*} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libnewt.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libnewt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnewt.so* $(1)/usr/lib/
endef

define Package/whiptail/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/whiptail $(1)/usr/bin/
endef

# Don't install files from usr/bin
Py3Package/python3-newt/install:=:

$(eval $(call BuildPackage,libnewt))
$(eval $(call BuildPackage,whiptail))

$(eval $(call Py3Package,python3-newt))
$(eval $(call BuildPackage,python3-newt))
$(eval $(call BuildPackage,python3-newt-src))
