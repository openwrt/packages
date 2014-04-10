#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mcast-tools
PKG_SOURCE_VERSION:=e5c860f174c6deb4cc30211e895831aca0a55b7f
PKG_VERSION:=2014-04-06
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/F0rth/mcast-tools.git
PKG_MAINTAINER:=Steven Barth <cyrus@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS+=--enable-mldv2host --disable-pim6dd --disable-mcastread --disable-mcastsend --disable-mfc --disable-mtrace6 --disable-pmsft
TARGET_CFLAGS+=-DIP6OPT_RTALERT_LEN=4 -D_GNU_SOURCE

define Package/pim6sd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Sparse PIM IPv6 Multicast Routing Daemon
endef

define Package/pim6sd/description
 pim6sd is an IPv6 multicast routing daemon, which supports PIMv2(Protocol
 Independent Multicast Version 2) sparse mode and SSM(Source-Specific-
 Multicast) for IPv6.
endef

define Package/pim6sd/conffiles
/etc/pim6sd.conf
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	( cd $(PKG_BUILD_DIR) ; \
		aclocal ; \
		autoheader ; \
		automake --add-missing; \
		autoconf ; \
	)
endef

define Package/pim6sd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_CONF) ./files/pim6sd.conf $(1)/etc
	$(INSTALL_BIN) ./files/pim6sd.init $(1)/etc/init.d/pim6sd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pim6sd/pim6sd $(1)/usr/sbin/pim6sd
endef

$(eval $(call BuildPackage,pim6sd))
