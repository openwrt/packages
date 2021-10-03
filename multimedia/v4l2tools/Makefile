#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=v4l2tools
PKG_VERSION:=0.1.5
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/v4l2tools.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=af63df7f88c1031aa5a438d175d77ca9c976e48eb55ff78a6ff6d2bd7272ac51

PKG_MAINTAINER:=Michel Promonet<michel.promonet@free.fr>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/v4l2tools
	SECTION:=multimedia
	CATEGORY:=Multimedia
	TITLE:=v4l2tools
	DEPENDS:=+libstdcpp +libjpeg
	URL:=https://github.com/mpromonet/v4l2tools
endef

define Package/v4l2tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v4l2tools-$(PKG_VERSION) $(1)/usr/bin/v4l2tools
endef

$(eval $(call BuildPackage,v4l2tools))
