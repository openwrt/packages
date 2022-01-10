#
# Copyright (C) 2016-2017 Dan Luedtke <mail@danrl.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=jool
PKG_VERSION:=4.1.6
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/NICMx/Jool/releases/download/v$(PKG_VERSION)
PKG_HASH:=dccfde88e3b97a7d1c44c53b6541b74873a04f50bb8cfd187eb399d5ae8d2c81

PKG_MAINTAINER:=
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/src/mod/common" \
		V="$(V)" \
		modules
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/src/mod/nat64" \
		V="$(V)" \
		modules
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/src/mod/siit" \
		V="$(V)" \
		modules
	$(call Build/Compile/Default)
endef


define Package/jool/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://www.jool.mx
endef

define Package/jool/Default/description
  Jool is an Open Source SIIT and NAT64 for Linux.
endef


define KernelPackage/jool
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=Jool kernel module
  DEPENDS:= \
    @IPV6 \
    +kmod-crypto-md5 \
    +kmod-nf-conntrack \
    +kmod-nf-conntrack6 \
    +kmod-nf-ipt
  FILES:= \
    $(PKG_BUILD_DIR)/src/mod/common/jool_common.$(LINUX_KMOD_SUFFIX) \
    $(PKG_BUILD_DIR)/src/mod/nat64/jool.$(LINUX_KMOD_SUFFIX) \
    $(PKG_BUILD_DIR)/src/mod/siit/jool_siit.$(LINUX_KMOD_SUFFIX)
  JOOL_AUTOLOAD:= \
    jool \
    jool_siit
  AUTOLOAD:=$(call AutoLoad,46,jool_common)
  AUTOLOAD:=$(call AutoLoad,48,$(JOOL_AUTOLOAD))
endef

define KernelPackage/jool/description
  $(call Package/jool/Default/description)

  This package provides the kernel module for Jool.
endef


define Package/jool-tools
  $(call Package/jool/Default)
  TITLE:=Jool userspace control programs
  DEPENDS:=+kmod-jool +libnl +libxtables
endef

define Package/jool-tools/description
  $(call Package/jool/Default/description)

  This package provides the userspace control programs for Jool.
endef


CONFIGURE_ARGS += \
	--disable-shared \
	--without-bash-completion-dir

CONFIGURE_VARS += \
	ac_cv_func_memset=yes \
	ac_cv_func_strcasecmp=yes

JOOL_AUTOLOAD:= \
	jool_common \
	jool \
	jool_siit

define Package/jool-tools/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/jool		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/joold		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/jool_siit	$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib/iptables
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/iptables/libxt_JOOL_SIIT.so \
		$(1)/usr/lib/iptables
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/iptables/libxt_JOOL.so \
		$(1)/usr/lib/iptables

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/jool.config $(1)/etc/config/jool

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/jool.init $(1)/etc/init.d/jool

	$(INSTALL_DIR) $(1)/etc/jool
	$(INSTALL_DATA) ./files/jool-nat64.conf.json $(1)/etc/jool/jool-nat64.conf.json.default
	$(INSTALL_DATA) ./files/jool-siit.conf.json $(1)/etc/jool/jool-siit.conf.json.default
	$(INSTALL_DATA) ./files/readme.md $(1)/etc/jool/readme.md
endef

$(eval $(call KernelPackage,jool))
$(eval $(call BuildPackage,jool-tools))
