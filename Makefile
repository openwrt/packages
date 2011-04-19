#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=batman-adv

PKG_VERSION:=2011.1.0
PKG_MD5SUM:=a05a3ff72bbc12859539f6a9e14af098
BATCTL_MD5SUM:=d3c7cca45c223a0ab80373fcb434dd5e

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)
PKG_TOOL_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/batctl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define KernelPackage/batman-adv
  URL:=http://www.open-mesh.org/
  MAINTAINER:=Marek Lindner <lindner_marek@yahoo.de>
  SUBMENU:=Network Support
  DEPENDS:=@!LINUX_2_4
  TITLE:=B.A.T.M.A.N. Adv
  FILES:=$(PKG_BUILD_DIR)/batman-adv.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,50,batman-adv)
endef

define KernelPackage/batman-adv/description
B.A.T.M.A.N. advanced is a kernel module which allows to
build layer 2 mesh networks. This package contains the
version $(PKG_VERSION) of the kernel module plus its user space
configuration & managerment tool batctl.
endef

define KernelPackage/batman-adv/config
	source "$(SOURCE)/Config.in"
endef

MAKE_BATMAN_ADV_ARGS += \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	ARCH="$(LINUX_KARCH)" \
	PATH="$(TARGET_PATH)" \
	$(if $(CONFIG_KMOD_BATMAN_ADV_DEBUG_LOG),EXTRA_CFLAGS="-DCONFIG_BATMAN_ADV_DEBUG") \
	SUBDIRS="$(PKG_BUILD_DIR)" \
	LINUX_VERSION="$(LINUX_VERSION)" \
	REVISION="" modules

MAKE_BATCTL_ARGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	CCFLAGS="$(TARGET_CFLAGS)" \
	OFLAGS="$(TARGET_CFLAGS)" \
	REVISION="" \
	CC="$(TARGET_CC)" \
	NODEBUG=1 \
	UNAME="Linux" \
	INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	batctl install

ifneq ($(DEVELOPER)$(CONFIG_KMOD_BATMAN_ADV_BATCTL),)
define Download/batctl
  FILE:=batctl-$(PKG_VERSION).tar.gz
  URL:=$(PKG_SOURCE_URL)
  MD5SUM:=$(BATCTL_MD5SUM)
endef
$(eval $(call Download,batctl))

BUILD_BATCTL = $(MAKE) -C $(PKG_TOOL_BUILD_DIR) $(MAKE_BATCTL_ARGS)
endif

define Build/Compile
	tar xzf "$(DL_DIR)/batctl-$(PKG_VERSION).tar.gz" -C "$(BUILD_DIR)/$(PKG_NAME)"
	cp $(PKG_BUILD_DIR)/Makefile.kbuild $(PKG_BUILD_DIR)/Makefile
	$(MAKE) -C "$(LINUX_DIR)" $(MAKE_BATMAN_ADV_ARGS)
	$(BUILD_BATCTL)
endef

define Build/Clean
        rm -rf $(BUILD_DIR)/$(PKG_NAME)/
endef

ifneq ($(DEVELOPER)$(CONFIG_KMOD_BATMAN_ADV_BATCTL),)
define KernelPackage/batman-adv/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/batman-adv $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/batman-adv $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/batctl $(1)/usr/sbin/
endef
else
define KernelPackage/batman-adv/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/batman-adv $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/batman-adv $(1)/etc/config
endef
endif

$(eval $(call KernelPackage,batman-adv))
