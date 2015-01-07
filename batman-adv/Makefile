#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=batman-adv

PKG_VERSION:=2014.4.0
PKG_RELEASE:=1
PKG_MD5SUM:=b1518e84ce530883d224c6ca4c673ce8

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define KernelPackage/batman-adv
  URL:=http://www.open-mesh.org/
  MAINTAINER:=Marek Lindner <mareklindner@neomailbox.ch>
  SUBMENU:=Network Support
  DEPENDS:=+KMOD_BATMAN_ADV_BLA:kmod-lib-crc16 +kmod-crypto-core +kmod-crypto-crc32c +kmod-lib-crc32c
  TITLE:=B.A.T.M.A.N. Adv
  FILES:=$(PKG_BUILD_DIR)/batman-adv.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,50,batman-adv)
endef

define KernelPackage/batman-adv/description
B.A.T.M.A.N. advanced is a kernel module which allows to
build layer 2 mesh networks. This package builds
version $(PKG_VERSION) of the kernel module.
endef

define KernelPackage/batman-adv/config
	source "$(SOURCE)/Config.in"
endef

define Package/kmod-batman-adv/conffiles
/etc/config/batman-adv
endef

MAKE_BATMAN_ADV_ARGS += \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	KERNELPATH="$(LINUX_DIR)" \
	ARCH="$(LINUX_KARCH)" \
	PATH="$(TARGET_PATH)" \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	PWD="$(PKG_BUILD_DIR)" \
	LINUX_VERSION="$(LINUX_VERSION)" \
	CONFIG_BATMAN_ADV_DEBUG=$(if $(CONFIG_KMOD_BATMAN_ADV_DEBUG_LOG),y,n) \
	CONFIG_BATMAN_ADV_BLA=$(if $(CONFIG_KMOD_BATMAN_ADV_BLA),y,n) \
	CONFIG_BATMAN_ADV_DAT=$(if $(CONFIG_KMOD_BATMAN_ADV_DAT),y,n) \
	CONFIG_BATMAN_ADV_MCAST=$(if $(CONFIG_KMOD_BATMAN_ADV_MCAST),y,n) \
	CONFIG_BATMAN_ADV_NC=$(if $(CONFIG_KMOD_BATMAN_ADV_NC),y,n) \
	REVISION="" all

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) '/#define _NET_BATMAN_ADV_MAIN_H_/a\#undef CONFIG_MODULE_STRIPPED' \
		$(PKG_BUILD_DIR)/main.h
endef

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)" $(MAKE_BATMAN_ADV_ARGS)
endef

define Build/Clean
        rm -rf $(BUILD_DIR)/$(PKG_NAME)/
endef

define KernelPackage/batman-adv/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/hotplug.d/net $(1)/etc/hotplug.d/iface $(1)/lib/batman-adv $(1)/usr/sbin $(1)/lib/netifd/proto
	$(INSTALL_DATA) ./files/etc/config/batman-adv $(1)/etc/config
	$(INSTALL_DATA) ./files/lib/batman-adv/config.sh $(1)/lib/batman-adv
	$(INSTALL_BIN) ./files/etc/hotplug.d/net/99-batman-adv $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/lib/netifd/proto/batadv.sh $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/lib/netifd/proto/batadv_vlan.sh $(1)/lib/netifd/proto
endef

$(eval $(call KernelPackage,batman-adv))
