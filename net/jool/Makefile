#
# Copyright (C) 2016-2017 Dan Luedtke <mail@danrl.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=jool
PKG_VERSION:=4.1.11
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NICMx/Jool.git
PKG_SOURCE_VERSION:=aed966aa4873af2d84fd445f49cf33f719539c9e
PKG_MIRROR_HASH:=b3acf9886ea287cf3e8ce8476ebfc3820b354411e18fafd6abab7aa220d5273f

PKG_BUILD_DIR=$(KERNEL_BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=!USE_GLIBC:argp-standalone

PKG_FIXUP:=autoreconf

MAKE_PATH:=src/usr
CONFIGURE_PATH:=src/usr

include $(INCLUDE_DIR)/package.mk

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/src/mod/common" \
		V="$(V)" \
		CFLAGS_MODULE=$(NOXTABLES) \
		modules
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/src/mod/nat64" \
		CFLAGS_MODULE=$(NOXTABLES) \
		V="$(V)" \
		modules
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		M="$(PKG_BUILD_DIR)/src/mod/siit" \
		CFLAGS_MODULE=$(NOXTABLES) \
		V="$(V)" \
		modules
	$(call Build/Compile/Default)
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); ./autogen.sh );
	$(call Build/Configure/Default, --with-xtables=no)
endef


define Package/jool/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://nicmx.github.io/Jool/
endef

define Package/jool/Default/description
  Jool is an Open Source SIIT and NAT64 for Linux.
endef


define KernelPackage/jool-netfilter
	SECTION:=kernel
	CATEGORY:=Kernel modules
	SUBMENU:=Network Support
	TITLE:=Jool kernel module
	DEPENDS:= \
		@IPV6 \
		+kmod-crypto-md5 \
		+kmod-nf-conntrack \
		+kmod-nf-conntrack6
	FILES:= \
		$(PKG_BUILD_DIR)/src/mod/common/jool_common.$(LINUX_KMOD_SUFFIX) \
		$(PKG_BUILD_DIR)/src/mod/nat64/jool.$(LINUX_KMOD_SUFFIX) \
		$(PKG_BUILD_DIR)/src/mod/siit/jool_siit.$(LINUX_KMOD_SUFFIX)
	AUTOLOAD:=$(call AutoLoad,48,$(JOOL_AUTOLOAD))
endef

define KernelPackage/jool-netfilter/description
  $(call Package/jool/Default/description)

  This package provides the kernel module for Jool with netfilter API Only.
endef


define Package/jool-tools-netfilter
  $(call Package/jool/Default)
  TITLE:=Jool userspace control programs
  DEPENDS:=+libnl +kmod-jool-netfilter
endef

define Package/jool-tools-netfilter/description
  $(call Package/jool/Default/description)

  This package provides the userspace control programs for Jool.
endef

JOOL_AUTOLOAD:= \
	jool \
	jool_siit

NOXTABLES:=-DXTABLES_DISABLED

define Package/jool-tools-netfilter/conffiles
/etc/config/jool
/etc/jool/jool-nat64.conf.json
/etc/jool/jool-siit.conf.json
endef

define Package/jool-tools-netfilter/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/usr/nat64/jool		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/usr/joold/joold		$(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/usr/siit/jool_siit	$(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/jool.config $(1)/etc/config/jool

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/jool.init $(1)/etc/init.d/jool

	$(INSTALL_DIR) $(1)/etc/jool
	$(INSTALL_CONF) ./files/jool-nat64.conf.json $(1)/etc/jool/jool-nat64.conf.json
	$(INSTALL_CONF) ./files/jool-siit.conf.json $(1)/etc/jool/jool-siit.conf.json
	$(INSTALL_DATA) ./files/readme.md $(1)/etc/jool/readme.md
endef

$(eval $(call KernelPackage,jool-netfilter))
$(eval $(call BuildPackage,jool-tools-netfilter))
