include $(TOPDIR)/rules.mk

PKG_NAME:=opengnb
PKG_VERSION:=1.6.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/opengnb/opengnb/archive/refs/tags/ver$(PKG_VERSION).tar.gz?
PKG_HASH:=218dcb7c52a734f5819c965ee54b87544c811712c1f467790bde7e83818b9f5a

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-ver$(PKG_VERSION)

PKG_MAINTAINER:= Charles Chan <hollidgelongsun157@gmail.com>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/opengnb
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=OpenGNB - P2P Decentralized Virtual Network
  URL:=https://github.com/opengnb/opengnb
  DEPENDS:=+libpthread +kmod-tun
endef

define Package/opengnb/description
  OpenGNB is an open source P2P decentralized Software Defined Virtual Network
  with extreme intranet penetration capability.
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I. -I./src -I./libs -I./libs/miniupnpc -I./libs/libnatpmp -I./libs/zlib -D_GNU_SOURCE -DNO_GZIP=1 -DGNB_OPENWRT_BUILD=1" \
		LDFLAGS="$(TARGET_LDFLAGS) -pthread" \
		-f Makefile.openwrt \
		all
endef

define Package/opengnb/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gnb $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gnb_crypto $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gnb_ctl $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,opengnb))
