#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# blogic@openwrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=lame
PKG_VERSION:=3.99.5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/lame
PKG_MD5SUM:=84835b313d4a8b68f5349816d33e07ce
PKG_FIXUP:=autoreconf

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>

PKG_LICENSE:=LGPL-2.0
PKG_LICENSE_FILES:=COPYING LICENSE

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL=1

define Package/lame/Default
  SECTION:=sound
  CATEGORY:=Sound
  URL:=http://sourceforge.net/projects/lame
  DEPENDS:=@BUILD_PATENTED
endef

define Package/lame
$(call Package/lame/Default)
  TITLE:=lame
  MENU:=1
  DEPENDS += +libncurses
endef

define Package/lame/description
lame mp3 encoder
endef

define Package/lame-lib
$(call Package/lame/Default)
  TITLE:=lame-lib
endef

define Package/lame-lib/description
lame mp3 encoder libs
endef

CONFIG_VARS+=NASM=no

ifeq ($(ARCH),i386)
TARGET_CFLAGS+=-msse
endif

define Package/lame/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lame $(1)/usr/bin/
endef

define Package/lame-lib/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/lame
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/include/lame/*.h \
		$(1)/usr/include/lame/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/*.{la,so*} \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,lame-lib))
$(eval $(call BuildPackage,lame))
