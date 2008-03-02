#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id$

include $(TOPDIR)/rules.mk

PKG_NAME:=batmand
PKG_REV:=963
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=1
PKG_BRANCH:=batman

PKG_SOURCE_PROTO:=svn
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_BRANCH)d-$(PKG_VERSION)
PKG_SOURCE_URL:=http://downloads.open-mesh.net/svn/batman/trunk/$(PKG_BRANCH)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

PKG_KMOD_BUILD_DIR:=$(PKG_BUILD_DIR)/linux/modules

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/batmand/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://www.open-mesh.net/
  MAINTAINER:=Marek Lindner <lindner_marek@yahoo.de>
endef

define Package/batmand
$(call Package/batmand/Default)
  DEPENDS:=+libpthread +kmod-tun
  TITLE:=B.A.T.M.A.N. layer 3 routing daemon
endef

define Package/batmand/description
B.A.T.M.A.N. layer 3 routing daemon
endef

define KernelPackage/batgat
$(call Package/batmand/Default)
  DEPENDS:=batmand
  TITLE:=B.A.T.M.A.N. gateway module
  FILES:=$(PKG_KMOD_BUILD_DIR)/batgat.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,50,batgat)
endef


define KernelPackage/batgat/description
Kernel gateway module for B.A.T.M.A.N.
endef

MAKE_ARGS += \
	EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
	CCFLAGS="$(TARGET_CFLAGS)" \
	OFLAGS="$(TARGET_CFLAGS)" \
	REVISION="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	NODEBUG=1 \
	UNAME="Linux" \
	INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	batmand install

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_ARGS)
	cp $(PKG_KMOD_BUILD_DIR)/Makefile.kbuild $(PKG_KMOD_BUILD_DIR)/Makefile
	$(MAKE) -C "$(LINUX_DIR)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		ARCH="$(LINUX_KARCH)" \
		PATH="$(TARGET_PATH)" \
		SUBDIRS="$(PKG_KMOD_BUILD_DIR)" \
		LINUX_VERSION="$(LINUX_VERSION)" \
		REVISION="$(PKG_REV)" modules
endef

define Package/batmand/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/batmand $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/batmand $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/batmand $(1)/etc/config
endef

$(eval $(call BuildPackage,batmand))
$(eval $(call KernelPackage,batgat))
