# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=luit
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://xorg.freedesktop.org/releases/individual/app/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=30b0e787cb07a0f504b70f1d6123930522111ce9d4276f6683a69b322b49c636

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luit
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libfontenc
  TITLE:=provides locale and ISO 2022 support for Unicode terminals
  URL:=http://xorg.freedesktop.org/
endef

TARGET_CFLAGS+=-U_XOPEN_SOURCE -D_XOPEN_SOURCE=600

define Package/luit/install
	$(INSTALL_DIR) \
	  $(1)/usr/bin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
endef

$(eval $(call BuildPackage,luit))

