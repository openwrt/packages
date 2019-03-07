#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=batman-adv

PKG_VERSION:=2019.0
PKG_RELEASE:=3
PKG_HASH:=3e97d8a771cdbd7b2df42c52b88e071eaa58b5d28eb4e17a4b13b6698debbdc0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)
PKG_LICENSE:=GPL-2.0
PKG_EXTMOD_SUBDIRS=net/batman-adv

STAMP_CONFIGURED_DEPENDS := $(STAGING_DIR)/usr/include/mac80211-backport/backport/autoconf.h

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/batman-adv
  URL:=https://www.open-mesh.org/
  MAINTAINER:=Simon Wunderlich <sw@simonwunderlich.de>
  SUBMENU:=Network Support
  DEPENDS:=+BATMAN_ADV_BLA:kmod-lib-crc16 +kmod-lib-crc32c +kmod-cfg80211 +batctl
  TITLE:=B.A.T.M.A.N. Adv
  FILES:=$(PKG_BUILD_DIR)/net/batman-adv/batman-adv.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoProbe,batman-adv)
endef

define KernelPackage/batman-adv/description
B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is
a routing protocol for multi-hop ad-hoc mesh networks. The
networks may be wired or wireless. See
https://www.open-mesh.org/ for more information and user space
tools. This package builds version $(PKG_VERSION) of the kernel
module.
endef

define KernelPackage/batman-adv/config
	source "$(SOURCE)/Config.in"
endef

define Package/kmod-batman-adv/conffiles
/etc/config/batman-adv
endef

PKG_EXTRA_KCONFIG:= \
	CONFIG_BATMAN_ADV=m \
	CONFIG_BATMAN_ADV_DEBUG=$(if $(CONFIG_BATMAN_ADV_DEBUG),y,n) \
	CONFIG_BATMAN_ADV_DEBUGFS=$(if $(CONFIG_BATMAN_ADV_DEBUGFS),y,n) \
	CONFIG_BATMAN_ADV_BLA=$(if $(CONFIG_BATMAN_ADV_BLA),y,n) \
	CONFIG_BATMAN_ADV_DAT=$(if $(CONFIG_BATMAN_ADV_DAT),y,n) \
	CONFIG_BATMAN_ADV_MCAST=$(if $(CONFIG_BATMAN_ADV_MCAST),y,n) \
	CONFIG_BATMAN_ADV_NC=$(if $(CONFIG_BATMAN_ADV_NC),y,n) \
	CONFIG_BATMAN_ADV_BATMAN_V=$(if $(CONFIG_BATMAN_ADV_BATMAN_V),y,n) \
	CONFIG_BATMAN_ADV_TRACING=$(if $(CONFIG_BATMAN_ADV_TRACING),y,n) \

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
	-include $(PKG_BUILD_DIR)/compat-hacks.h \
	-DBATADV_SOURCE_VERSION=\\\"openwrt-$(PKG_VERSION)-$(PKG_RELEASE)\\\"

COMPAT_SOURCES = \
	$(if $(CONFIG_BATMAN_ADV_MCAST),../../compat-sources/net/core/skbuff.o,) \
	$(if $(CONFIG_BATMAN_ADV_MCAST),../../compat-sources/net/ipv4/igmp.o,) \
	$(if $(CONFIG_BATMAN_ADV_MCAST),../../compat-sources/net/ipv6/mcast_snoop.o,) \

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

define KernelPackage/batman-adv/install
	$(CP) ./files/. $(1)/
endef

$(eval $(call KernelPackage,batman-adv))
