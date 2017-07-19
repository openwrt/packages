# Copyright (C) 2009 Ambroz Bizjak
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=badvpn
PKG_VERSION:=1.999.130
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=HEAD
PKG_SOURCE_URL:=https://github.com/ambrop72/badvpn.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION)-$(PKG_RELEASE).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
PKG_MD5SUM:=0b5a9ea860841209eca421707ad1b109
PKG_MAINTAINER:=Galih Prastowo Aji <galih.prastowo@gmail.com>
	
include $(INCLUDE_DIR)/package.mk

define Package/badvpn
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+librt +libpthread +udev +coreutils +coreutils-stdbuf
	TITLE:=BadVPN
	SUBMENU:=VPN
endef

define Package/badvpn/description
	BadVPN creates a transparent proxy of your SSH tunnel,
	so you won't have to set your browser's proxy manually.
endef

define Build/Configure
	echo -e \
	"SET(CMAKE_SYSTEM_NAME Linux)\n" \
	"SET(CMAKE_C_COMPILER $(TARGET_CC))\n" \
	"SET(CMAKE_CXX_COMPILER $(TARGET_CXX))\n" \
	"SET(CMAKE_FIND_ROOT_PATH $(STAGING_DIR) $(STAGING_DIR_HOST))\n" \
	> "$(PKG_BUILD_DIR)/toolchain.cmake"
	(cd $(PKG_BUILD_DIR); \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		cmake . \
		-DCMAKE_TOOLCHAIN_FILE=$(PKG_BUILD_DIR)/toolchain.cmake \
		-DBUILD_NOTHING_BY_DEFAULT=1 \
		-DBUILD_TUN2SOCKS=1 \
	);
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/badvpn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tun2socks/badvpn-tun2socks $(1)/usr/bin/badvpn-tun2socks
endef

$(eval $(call BuildPackage,badvpn))
