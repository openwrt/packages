#
# Copyright (C) 2014-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cshark
PKG_VERSION:=2015-03-13
PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cloudshark/cshark.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=ab2ae2fbd72b6cbd57c95e3192edc3c1f475412b
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/cshark
  SECTION:=net
  CATEGORY:=Network
  TITLE:=CloudShark capture tool
  URL:=http://www.cloudshark.org/
  DEPENDS:=+libjson-c +libpcap +libuci +libubox +libuclient +libustream-polarssl
  MAINTAINER:=Luka Perkov <luka@openwrt.org>
endef

define Package/luci-app-cshark
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Cloudshark capture tool Web UI
  DEPENDS:=+cshark +luci
  MAINTAINER:=Luka Perkov <luka@openwrt.org>
endef

CMAKE_OPTIONS = \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DWITH_DEBUG=OFF \

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

define Package/luci-app-cshark/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) -R $(PKG_BUILD_DIR)/openwrt/luci/luasrc/* $(1)/usr/lib/lua/luci/
endef

$(eval $(call BuildPackage,cshark))
$(eval $(call BuildPackage,luci-app-cshark))
