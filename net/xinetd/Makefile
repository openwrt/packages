#
# Copyright (C) 2006-2025 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xinetd
PKG_VERSION:=2.3.15.4
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/openSUSE/xinetd
PKG_MIRROR_HASH:=7268c75ce6f4cd64fa62172849c5361d38f05b6be0fac889ed2012d3d9547639

PKG_MAINTAINER:=Florian Eckert <fe@dev.tdt.de>
PKG_LICENSE:=xinetd
PKG_LICENSE_FILES:=COPYRIGHT
PKG_CPE_ID:=cpe:/a:xinetd:xinetd

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xinetd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A powerful and secure super-server
  URL:=https://github.com/openSUSE/xinetd
  DEPENDS:= +USE_GLIBC:libcrypt-compat
endef

define Package/xinetd/description
	xinetd has access control mechanisms, extensive logging capabilities,
	the ability to make services available based on time, can place limits
	on the number of servers that can be started, and has deployable
	defence mechanisms to protect against port scanners, among other
	things.
endef

define Package/xinetd/conffiles
/etc/config/xinetd
/etc/xinetd.d
endef

CONFIGURE_ARGS += \
	--without-libwrap \
	--with-loadavg \
	--without-rpc \
	--without-labeled-networking

define Package/xinetd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/xinetd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DATA) ./files/xinetd.uci.conf.sample $(1)/etc/config/xinetd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xinetd.init $(1)/etc/init.d/xinetd
	$(INSTALL_DIR) $(1)/etc/xinetd.d
endef

$(eval $(call BuildPackage,xinetd))
