#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cshark
PKG_SOURCE_DATE:=2018-08-20
PKG_SOURCE_VERSION:=7a7cf7f35074b85c6fb0c52067e640d2433ef73b
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cloudshark/cshark.git
PKG_MIRROR_HASH:=b09822e93d7de7f4aa9fa018c304ebc52dd3419de3dd2eff463986d3a3b8ca71

PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>
PKG_LICENSE:=BSD-2-Clause

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/cshark
  SECTION:=net
  CATEGORY:=Network
  TITLE:=CloudShark capture tool
  URL:=https://cloudshark.io/
  DEPENDS:=+libjson-c +libpcap +libuci +libubox +libuclient +libustream-mbedtls
endef

CMAKE_OPTIONS = \
	-DWITH_DEBUG=OFF

define Package/cshark/conffiles
/etc/config/cshark
endef

define Package/cshark/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/cshark \
		$(1)/sbin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) \
		$(PKG_BUILD_DIR)/config/cshark \
		$(1)/etc/config/

	$(INSTALL_DIR) $(1)/etc/ssl/certs
	$(INSTALL_CONF) \
		$(PKG_BUILD_DIR)/config/ca-the_usertrust_network.pem \
		$(1)/etc/ssl/certs/
endef


$(eval $(call BuildPackage,cshark))
