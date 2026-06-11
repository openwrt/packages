#
# Copyright 2026 Charles Chan <hollidgelongsun157@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.0-or-later
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opengnb
PKG_VERSION:=1.6.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/opengnb/opengnb/archive/refs/tags/
PKG_HASH:=227be9cee64b4e4250273e8ad4440e7213b7ef511f8a813948e5132f1cc4a3b2

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:= Charles Chan <hollidgelongsun157@gmail.com>
PKG_LICENSE:= GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/opengnb
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=OpenGNB - P2P Decentralized Virtual Network
  URL:=https://github.com/opengnb/opengnb
  DEPENDS:=+libpthread +kmod-tun +zlib +miniupnpc +libnatpmp
endef

define Package/opengnb/description
  OpenGNB is an open source P2P decentralized Software Defined Virtual Network
  with extreme intranet penetration capability.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)      \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I. -I./src -I./libs -I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/miniupnpc -D_GNU_SOURCE -DNO_GZIP=1 -DGNB_OPENWRT_BUILD=1" \
		LDFLAGS="$(TARGET_LDFLAGS) -L$(STAGING_DIR)/usr/lib -lz -lminiupnpc -lnatpmp -pthread" \
		-f Makefile.openwrt      \
		all
endef

define Package/opengnb/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gnb $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gnb_crypto $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gnb_ctl $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,opengnb))
