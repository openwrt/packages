#
# Copyright (C) 2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=batman-adv

PKG_VERSION:=2012.0.0
BATCTL_VERSION:=2012.0.0
PKG_MD5SUM:=f1de23457a47ca4369ee1f0e0b7fc405
BATCTL_MD5SUM:=27991c2921e18657c7262e917d45106a

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://downloads.open-mesh.org/batman/releases/batman-adv-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BATCTL_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/batctl-$(BATCTL_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define KernelPackage/batman-adv
  URL:=http://www.open-mesh.org/
  MAINTAINER:=Marek Lindner <lindner_marek@yahoo.de>
  SUBMENU:=Network Support
  DEPENDS:=+kmod-lib-crc16
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
	DESTDIR="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	batctl install

ifneq ($(DEVELOPER)$(CONFIG_KMOD_BATMAN_ADV_BATCTL),)
define Download/batctl
  FILE:=batctl-$(BATCTL_VERSION).tar.gz
  URL:=$(PKG_SOURCE_URL)
  MD5SUM:=$(BATCTL_MD5SUM)
endef
$(eval $(call Download,batctl))

BATCTL_EXTRACT = tar xzf "$(DL_DIR)/batctl-$(BATCTL_VERSION).tar.gz" -C "$(BUILD_DIR)/$(PKG_NAME)"
BATCTL_PATCH = $(call Build/DoPatch,"$(PKG_BATCTL_BUILD_DIR)","$(PATCH_DIR)","*batctl*")
BATCTL_BUILD = $(MAKE) -C $(PKG_BATCTL_BUILD_DIR) $(MAKE_BATCTL_ARGS)
BATCTL_INSTALL = $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/sbin/batctl $(1)/usr/sbin/
endif

KPATCH ?= $(PATCH)
define Build/DoPatch
	@if [ -d "$(2)" ]; then \
		if [ "$$$$(ls $(2) | grep -Ec $(3))" -gt 0 ]; then \
			$(KPATCH) "$(1)" "$(2)" "$(3)"; \
		fi; \
	fi
endef

define Build/Patch
	$(call Build/DoPatch,"$(PKG_BUILD_DIR)","$(PATCH_DIR)","*batman*")
	$(BATCTL_EXTRACT)
	$(BATCTL_PATCH)
endef

define Build/Compile
	cp $(PKG_BUILD_DIR)/Makefile.kbuild $(PKG_BUILD_DIR)/Makefile
	$(MAKE) -C "$(LINUX_DIR)" $(MAKE_BATMAN_ADV_ARGS)
	$(BATCTL_BUILD)
endef

define Build/Clean
        rm -rf $(BUILD_DIR)/$(PKG_NAME)/
endef

define KernelPackage/batman-adv/install
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/hotplug.d/net $(1)/lib/batman-adv $(1)/usr/sbin
	$(INSTALL_DATA) ./files/etc/config/batman-adv $(1)/etc/config
	$(INSTALL_DATA) ./files/lib/batman-adv/config.sh $(1)/lib/batman-adv
	$(INSTALL_BIN) ./files/etc/hotplug.d/net/99-batman-adv $(1)/etc/hotplug.d/net
	$(INSTALL_BIN) ./files/usr/sbin/batman-adv $(1)/usr/sbin
	$(BATCTL_INSTALL)
endef

$(eval $(call KernelPackage,batman-adv))
