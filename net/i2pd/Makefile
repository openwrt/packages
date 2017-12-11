#
# Copyright (C) 2015, 2016 gxcreator
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=i2pd
PKG_VERSION:=2.17.0
PKG_RELEASE:=1
PKG_BUILD_PARALLEL:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/PurpleI2P/i2pd.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=d389615366e603468c6d213e6545dfea99090d4a83aac121b6e2e4e5d0aac925
PKG_LICENSE:=BSD-3-clause

include $(INCLUDE_DIR)/package.mk

define Package/i2pd
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libopenssl +boost +boost-system +boost-filesystem +boost-regex \
		 +boost-program_options +boost-date_time +libatomic +zlib
	TITLE:=full-featured C++ implementation of I2P client
	URL:=https://github.com/PurpleI2P/i2pd
	MAINTAINER:=David Yang <mmyangfl@gmail.com>
endef

define Package/i2pd/description
	I2P (Invisible Internet Protocol) is a universal anonymous network layer. All
	communications over I2P are anonymous and end-to-end encrypted, participants
	don't reveal their real IP addresses.
endef

define Package/i2pd/conffiles
	/etc/i2pd/i2pd.conf
	/etc/i2pd/subscriptions.txt
	/etc/i2pd/tunnels.conf
endef

MAKE_FLAGS+=USE_AESNI=no USE_AVX=no

define Package/i2pd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/i2pd $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/i2pd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/i2pd.conf $(1)/etc/i2pd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/subscriptions.txt $(1)/etc/i2pd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/contrib/tunnels.conf $(1)/etc/i2pd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/i2pd.init $(1)/etc/init.d/i2pd
endef

$(eval $(call BuildPackage,i2pd))
