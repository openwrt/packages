# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xauth
PKG_VERSION:=1.0.10
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.x.org/releases/individual/app/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_HASH:=5afe42ce3cdf4f60520d1658d2b17face45c74050f39af45dccdc95e73fafc4d

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xauth
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxau +libxext +libxmu
  TITLE:=X.Org authorization settings program
  URL:=http://xorg.freedesktop.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CONFIGURE_ARGS += \
  --prefix=/usr

define Package/xauth/install
	$(INSTALL_DIR) \
	  $(1)/usr/sbin

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,xauth))
