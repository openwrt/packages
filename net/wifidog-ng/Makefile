#
# Copyright (C) 2014-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wifidog-ng
PKG_VERSION:=1.5.6
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/zhaojh329/wifidog-ng.git
PKG_MIRROR_HASH:=a81e9a4d5feb3facbe1b2b55d2d813944b569865f53421680efbfc6876aa3f5d

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_SOURCE_SUBDIR)

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jianhui Zhao <jianhuizhao329@gmail.com>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/wifidog-ng/default
  SUBMENU:=Captive Portals
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Next generation WifiDog
  DEPENDS:=+kmod-wifidog-ng +libuci +libuclient +libblobmsg-json +libubus +libcares \
	  +ipset +libpcap
endef

define Package/wifidog-ng-nossl
  $(Package/wifidog-ng/default)
  TITLE += (NO SSL)
  DEPENDS += +libuhttpd-nossl
  VARIANT:=nossl
  CONFLICTS:=wifidog-ng-openssl wifidog-ng-wolfssl wifidog-ng-mbedtls
endef

define Package/wifidog-ng-openssl
  $(Package/wifidog-ng/default)
  TITLE += (openssl)
  DEPENDS += +libuhttpd-openssl
  VARIANT:=openssl
  CONFLICTS:=wifidog-ng-wolfssl wifidog-ng-mbedtls
endef

define Package/wifidog-ng-wolfssl
  $(Package/wifidog-ng/default)
  TITLE += (wolfssl)
  DEPENDS += +libuhttpd-wolfssl
  VARIANT:=wolfssl
  CONFLICTS:=wifidog-ng-mbedtls
endef

define Package/wifidog-ng-mbedtls
  $(Package/wifidog-ng/default)
  TITLE += (mbedtls)
  DEPENDS += +libuhttpd-mbedtls
  VARIANT:=mbedtls
endef

define Package/wifidog-ng/default/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/config \
		$(1)/etc/wifidog-ng $(1)//etc/hotplug.d/dhcp
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/wifidog-ng $(1)/usr/bin
	$(INSTALL_BIN) ./files/wifidog-ng.init $(1)/etc/init.d/wifidog-ng
	$(INSTALL_CONF) ./files/wifidog-ng.config $(1)/etc/config/wifidog-ng
	$(INSTALL_CONF) ./files/wifidog-ng.key $(1)/etc/wifidog-ng
	$(INSTALL_CONF) ./files/wifidog-ng.crt $(1)/etc/wifidog-ng
	$(INSTALL_DATA) ./files/wifidog-ng.hotplug $(1)/etc/hotplug.d/dhcp/00-wifidog-ng
endef

Package/wifidog-ng-nossl/install = $(Package/wifidog-ng/default/install)
Package/wifidog-ng-openssl/install = $(Package/wifidog-ng/default/install)
Package/wifidog-ng-wolfssl/install = $(Package/wifidog-ng/default/install)
Package/wifidog-ng-mbedtls/install = $(Package/wifidog-ng/default/install)

include $(INCLUDE_DIR)/kernel.mk

define KernelPackage/wifidog-ng
  SUBMENU:=Other modules
  TITLE:=Kernel module for wifidog-ng
  DEPENDS:=+kmod-nf-nat +kmod-ipt-ipset
  FILES:=$(PKG_BUILD_DIR)/kmod/wifidog-ng.ko
endef

include $(INCLUDE_DIR)/kernel-defaults.mk

define Build/Compile
	$(call Build/Compile/Default)
	$(MAKE) $(KERNEL_MAKEOPTS) SUBDIRS="$(PKG_BUILD_DIR)"/kmod modules
endef

$(eval $(call BuildPackage,wifidog-ng-nossl))
$(eval $(call BuildPackage,wifidog-ng-mbedtls))
$(eval $(call BuildPackage,wifidog-ng-wolfssl))
$(eval $(call BuildPackage,wifidog-ng-openssl))

$(eval $(call KernelPackage,wifidog-ng))
