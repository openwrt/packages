#
# Copyright (C) 2017 Jian Chang <aa65535@live.com> & V.E.O
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=simple-obfs
PKG_VERSION:=0.0.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/V-E-O/simple-obfs.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE_VERSION:=237fd82b58b8750f33cfa69d78c70228e21eb90c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com> & V.E.O

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(PKG_SOURCE_SUBDIR)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/simple-obfs/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Simple-obfs
	URL:=https://github.com/V-E-O/simple-obfs
	DEPENDS:=+libev +libudns +libpthread +libsodium
endef

Package/simple-obfs = $(call Package/simple-obfs/Default)
Package/simple-obfs-server = $(call Package/simple-obfs/Default)

define Package/simple-obfs/description
Simple-obfs is a simple obfusacting tool, designed as plugin server of shadowsocks.
endef

Package/simple-obfs-server/description = $(Package/simple-obfs/description)

CONFIGURE_ARGS += --disable-ssp --disable-documentation --disable-assert

define Package/simple-obfs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/obfs-local $(1)/usr/bin
endef

define Package/simple-obfs-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/obfs-server $(1)/usr/bin
endef

$(eval $(call BuildPackage,simple-obfs))
$(eval $(call BuildPackage,simple-obfs-server))
