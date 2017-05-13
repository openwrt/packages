#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=netdiscover
PKG_VERSION:=0.3-pre-beta7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-LINUXONLY.tar.gz
PKG_SOURCE_URL:=@SF/netdiscover
PKG_MD5SUM:=8780e66d00496e933b4064cfe9ae61da
PKG_MAINTAINER:=Mislav Novakovic <mislav.novakovic@sartura.hr>
PKG_LICENSE:=GPL-2.0

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/netdiscover
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap +libnet-1.2.x +libpthread
  TITLE:=An active/passive address reconnaissance tool
  URL:=https://sourceforge.net/projects/netdiscover
endef

CONFIGURE_VARS+= \
	CPPFLAGS="$(TARGET_CPPFLAGS) -I$(STAGING_DIR)/usr/lib/libnet-1.2.x/lib" \
	LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib/libnet-1.2.x/lib"

define Package/netdiscover/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/netdiscover $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,netdiscover))
