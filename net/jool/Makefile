#
# Copyright (C) 2016-2017 Dan Luedtke <mail@danrl.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=jool
PKG_VERSION:=2018.01.17
PKG_RELEASE:=2

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NICMx/Jool.git
PKG_SOURCE_VERSION:=9dfaf22e49f7905d94af9b73f9bee22c26d7dd4a
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=79b558561f06f3df01a541b1d39b7d3d88f91d0ee6b8ce3abf91ebbed737225a

PKG_BUILD_DIR=$(KERNEL_BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=USE_UCLIBC:argp-standalone USE_MUSL:argp-standalone

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

MAKE_PATH:=usr
CONFIGURE_PATH:=usr

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)/mod/stateful" \
		V="$(V)" \
		modules
	$(MAKE) -C "$(LINUX_DIR)" \
		KERNEL_DIR="$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)/mod/stateless" \
		V="$(V)" \
		modules
	$(call Build/Compile/Default)
endef


define Package/jool/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://www.jool.mx
  MAINTAINER:=Dan Luedtke <mail@danrl.com>
endef

define Package/jool/Default/description
  Jool is an Open Source SIIT and NAT64 for Linux.
endef

define Package/jool
  $(call Package/jool/Default)
  TITLE:=Jool meta-package
  DEPENDS:=+kmod-jool +jool-tools
endef

define Package/jool/description
  $(call Package/jool/Default/description)
endef

define Package/jool-stateful
  $(call Package/jool/Default)
  TITLE:=Jool stateful meta-package
  DEPENDS:=+kmod-jool-stateful +jool-tools-stateful
endef

define Package/jool-stateful/description
  $(call Package/jool/Default/description)
  
  This meta-package provides only the stateful Jool tools and stateful kernel module.
endef

define Package/jool-stateless
  $(call Package/jool/Default)
  TITLE:=Jool stateless meta-package
  DEPENDS:=+kmod-jool-stateless +jool-tools-stateless
endef

define Package/jool-stateless/description
  $(call Package/jool/Default/description)
  
  This meta-package provides the stateless Jool tools and stateless kernel module.
endef

define KernelPackage/jool/Default
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  DEPENDS:= \
    @IPV6 \
    +kmod-crypto-md5 \
    +kmod-nf-conntrack \
    +kmod-nf-conntrack6
endef

define KernelPackage/jool
  $(call Package/jool/Default)
  TITLE:=Jool kernel modules meta-package
  DEPENDS:=+kmod-jool-stateful +kmod-jool-stateless
endef

define KernelPackage/jool-stateful
  $(call KernelPackage/jool/Default)
  TITLE:=Jool stateful kernel module
  FILES:=$(PKG_BUILD_DIR)/mod/stateful/jool.$(LINUX_KMOD_SUFFIX)
endef

define KernelPackage/jool-stateful/description
  $(call Package/jool/Default/description)

  This package provides the Jool stateful kernel module.
endef

define KernelPackage/jool-stateless
  $(call KernelPackage/jool/Default)
  TITLE:=Jool stateless kernel module
  FILES:=$(PKG_BUILD_DIR)/mod/stateless/jool_siit.$(LINUX_KMOD_SUFFIX)
endef

define KernelPackage/jool-stateless/description
  $(call Package/jool/Default/description)

  This package provides the Jool stateless kernel module.
endef

define Package/jool-tools
  $(call Package/jool/Default)
  TITLE:=Jool userspace control programs meta-package
  DEPENDS:=+jool-tools-stateful +jool-tools-stateless
endef

define Package/jool-tools/description
  $(call Package/jool/Default/description)

  This meta-package provides the stateful and stateless userspace control programs for Jool.
endef

define Package/jool-tools-stateful
  $(call Package/jool/Default)
  TITLE:=Jool stateful userspace control program
  DEPENDS:=+libnl +ethtool
endef

define Package/jool-tools-stateful/description
  $(call Package/jool/Default/description)

  This package provides the stateful userspace control program for Jool.
endef

define Package/jool-tools-stateless
  $(call Package/jool/Default)
  TITLE:=Jool stateless userspace control program
  DEPENDS:=+libnl +ethtool
endef

define Package/jool-tools-stateless/description
  $(call Package/jool/Default/description)

  This package provides the stateless userspace control program for Jool.
endef

define Package/jool-tools-stateful/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/stateful/jool       $(1)/usr/sbin/
endef

define Package/jool-tools-stateless/install
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usr/stateless/jool_siit $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,jool))
$(eval $(call BuildPackage,jool-stateful))
$(eval $(call BuildPackage,jool-stateless))
$(eval $(call KernelPackage,jool))
$(eval $(call KernelPackage,jool-stateful))
$(eval $(call KernelPackage,jool-stateless))
$(eval $(call BuildPackage,jool-tools))
$(eval $(call BuildPackage,jool-tools-stateful))
$(eval $(call BuildPackage,jool-tools-stateless))
