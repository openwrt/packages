#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=batmand

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.open-mesh.org/batmand.git
PKG_REV:=b67a7087b51d7a5e90d27ac39116d1f57257c86e
PKG_VERSION:=1440
PKG_RELEASE:=0
PKG_LICENSE:=GPL-2.0

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_MIRROR_HASH:=ceb8e0e399f79b1b663594fcf9642e1efc40e696a7604daf709c77da9b6ec52f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_EXTRA_CFLAGS=-DDEBUG_MALLOC -DMEMORY_USAGE -DPROFILE_DATA -DREVISION_VERSION=\"\ rv$(PKG_REV)\" -D_GNU_SOURCE

PKG_KMOD_BUILD_DIR:=$(PKG_BUILD_DIR)/linux/modules

include $(INCLUDE_DIR)/package.mk

define Package/batmand/Default
  URL:=https://www.open-mesh.org/
  MAINTAINER:=Corinna "Elektra" Aichele <onelektra@gmx.net>
endef

define Package/batmand
$(call Package/batmand/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+libpthread +kmod-tun
  TITLE:=B.A.T.M.A.N. layer 3 routing daemon
endef

define Package/batmand/description
B.A.T.M.A.N. layer 3 routing daemon
endef

define KernelPackage/batgat
$(call Package/batmand/Default)
  SUBMENU:=Network Support
  DEPENDS:=+batmand @BROKEN
  TITLE:=B.A.T.M.A.N. gateway module
  FILES:=$(PKG_KMOD_BUILD_DIR)/batgat.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,50,batgat)
endef


define KernelPackage/batgat/description
Kernel gateway module for B.A.T.M.A.N. for better tunnel performance
endef

MAKE_BATMAND_ARGS += \
	EXTRA_CFLAGS='$(TARGET_CFLAGS) $(PKG_EXTRA_CFLAGS)' \
	CCFLAGS="$(TARGET_CFLAGS)" \
	OFLAGS="$(TARGET_CFLAGS)" \
	REVISION="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	NODEBUG=1 \
	UNAME="Linux" \
	INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	batmand install

MAKE_BATGAT_ARGS += \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	ARCH="$(LINUX_KARCH)" \
	PATH="$(TARGET_PATH)" \
	SUBDIRS="$(PKG_KMOD_BUILD_DIR)" \
	LINUX_VERSION="$(LINUX_VERSION)" \
	REVISION="$(PKG_REV)" modules


define Build/Configure
endef

ifneq ($(DEVELOPER)$(CONFIG_PACKAGE_batmand),)
	BUILD_BATMAND := $(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_BATMAND_ARGS)
endif

ifneq ($(DEVELOPER)$(CONFIG_PACKAGE_kmod-batgat),)
	BUILD_BATGAT := $(MAKE) -C "$(LINUX_DIR)" $(MAKE_BATGAT_ARGS)
endif

define Build/Compile
	$(BUILD_BATMAND)
	cp $(PKG_KMOD_BUILD_DIR)/Makefile.kbuild $(PKG_KMOD_BUILD_DIR)/Makefile
	$(BUILD_BATGAT)
endef

define Package/batmand/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/batmand $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/batmand $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/batmand $(1)/etc/config
endef

define Package/batmand/conffiles
/etc/config/batmand
endef

$(eval $(call BuildPackage,batmand))
$(eval $(call KernelPackage,batgat))
