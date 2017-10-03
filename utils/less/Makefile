#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=less
PKG_VERSION:=487
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.greenwoodsoftware.com/less
PKG_HASH:=f3dc8455cb0b2b66e0c6b816c00197a71bf6d1787078adeee0bcf2aea4b12706

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Julen Landa Alustiza <julen@zokormazo.info>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/less/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Pager program similar to more
  URL:=http://www.greenwoodsoftware.com/less/
endef

define Package/less/Default/description
  Full version of GNU less utility
endef

define Package/less
  $(call Package/less/Default)
  DEPENDS:=+libncurses
  VARIANT:=narrow
endef

define Package/less/description
  $(call Package/less/Default/description)
endef

define Package/less-wide
  $(call Package/less/Default)
  TITLE+= (Unicode)
  DEPENDS:=+libncursesw
  VARIANT:=wide
endef

define Package/less-wide/description
  $(call Package/less/Default/description)
  This package contains the Unicode enabled version of less.
endef

ifeq ($(BUILD_VARIANT),narrow)
	CONFIGURE_VARS += \
		ac_cv_lib_ncursesw_initscr=no		
endif

ifeq ($(BUILD_VARIANT),wide)
	CONFIGURE_VARS += \
		ac_cv_lib_ncursesw_initscr=yes
endif

define Package/less/install
	$(INSTALL_DIR) $(1)/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/less $(1)/bin/less
endef

define Package/less/postinst
#!/bin/sh
[ -L "$${IPKG_INSTROOT}/usr/bin/less" ] && rm -f "$${IPKG_INSTROOT}/usr/bin/less"
exit 0
endef

define Package/less/postrm
#!/bin/sh
/bin/busybox less -h 2>&1 | grep -q BusyBox && ln -sf ../../bin/busybox /usr/bin/less
exit 0
endef

Package/less-wide/install = $(Package/less/install)
Package/less-wide/postinst = $(Package/less/postinst)
Package/less-wide/postrm = $(Package/less/postrm)

$(eval $(call BuildPackage,less))
$(eval $(call BuildPackage,less-wide))
