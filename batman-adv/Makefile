#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=batman-adv

PKG_VERSION:=2016.5
PKG_RELEASE:=0
PKG_MD5SUM:=6717a933a08dd2a01b00df30cb9f16a8

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define KernelPackage/batman-adv
  URL:=https://www.open-mesh.org/
  MAINTAINER:=Marek Lindner <mareklindner@neomailbox.ch>
  SUBMENU:=Network Support
  DEPENDS:=+KMOD_BATMAN_ADV_BLA:kmod-lib-crc16 +kmod-crypto-crc32c +kmod-lib-crc32c +kmod-cfg80211
  TITLE:=B.A.T.M.A.N. Adv
  FILES:=$(PKG_BUILD_DIR)/net/batman-adv/batman-adv.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,50,cfg80211 batman-adv)
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

PKG_EXTRA_KCONFIG:= \
	CONFIG_BATMAN_ADV=m \
	CONFIG_BATMAN_ADV_DEBUG=$(if $(CONFIG_KMOD_BATMAN_ADV_DEBUG_LOG),y,n) \
	CONFIG_BATMAN_ADV_DEBUGFS=$(if $(CONFIG_KMOD_BATMAN_ADV_DEBUGFS),y,n) \
	CONFIG_BATMAN_ADV_BLA=$(if $(CONFIG_KMOD_BATMAN_ADV_BLA),y,n) \
	CONFIG_BATMAN_ADV_DAT=$(if $(CONFIG_KMOD_BATMAN_ADV_DAT),y,n) \
	CONFIG_BATMAN_ADV_MCAST=$(if $(CONFIG_KMOD_BATMAN_ADV_MCAST),y,n) \
	CONFIG_BATMAN_ADV_NC=$(if $(CONFIG_KMOD_BATMAN_ADV_NC),y,n) \
	CONFIG_BATMAN_ADV_BATMAN_V=$(if $(CONFIG_KMOD_BATMAN_ADV_BATMAN_V),y,n) \

PKG_EXTRA_CFLAGS:= \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=m,%,$(filter %=m,$(PKG_EXTRA_KCONFIG)))) \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=y,%,$(filter %=y,$(PKG_EXTRA_KCONFIG)))) \

NOSTDINC_FLAGS = \
	-I$(PKG_BUILD_DIR)/net/batman-adv \
	-I$(STAGING_DIR)/usr/include/mac80211-backport \
	-I$(STAGING_DIR)/usr/include/mac80211-backport/uapi \
	-I$(STAGING_DIR)/usr/include/mac80211 \
	-I$(STAGING_DIR)/usr/include/mac80211/uapi \
	-I$(PKG_BUILD_DIR)/include/ \
	-include backport/backport.h \
	-include $(PKG_BUILD_DIR)/compat-hacks.h

COMPAT_SOURCES = \
	$(if $(CONFIG_KMOD_BATMAN_ADV_MCAST),../../compat-sources/net/core/skbuff.o,) \
	$(if $(CONFIG_KMOD_BATMAN_ADV_MCAST),../../compat-sources/net/ipv4/igmp.o,) \
	$(if $(CONFIG_KMOD_BATMAN_ADV_MCAST),../../compat-sources/net/ipv6/mcast_snoop.o,) \

define Build/Compile
	+env "batman-adv-y=$(COMPAT_SOURCES)" \
	$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)/net/batman-adv" \
		$(PKG_EXTRA_KCONFIG) \
		EXTRA_CFLAGS="$(PKG_EXTRA_CFLAGS)" \
		NOSTDINC_FLAGS="$(NOSTDINC_FLAGS)" \
		modules
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) ./files/compat-hacks.h $(PKG_BUILD_DIR)/
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
