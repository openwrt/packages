#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=transmission
PKG_VERSION:=4.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/transmission/transmission/releases/download/$(PKG_VERSION)/
PKG_HASH:=dcd28c1c9e6126229c4c17dbc9e95c9fd4aed7e76f4a1f2a74604c8cddec49d6

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:transmissionbt:transmission

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=libb64
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=gc-sections lto
PKG_CONFIG_DEPENDS:= \
	CONFIG_LIBCURL_GNUTLS \
	CONFIG_LIBCURL_MBEDTLS \
	CONFIG_LIBCURL_OPENSSL \
	CONFIG_LIBCURL_WOLFSSL \
	CONFIG_LIBCURL_NOSSL

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/package-seccomp.mk
include $(INCLUDE_DIR)/nls.mk

define Package/transmission/template
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BitTorrent client
  URL:=https://www.transmissionbt.com
  DEPENDS:=+libatomic +libcurl +libdeflate +libdht +libevent2 \
	   +libevent2-pthreads +libminiupnpc +libnatpmp +libpthread +libpsl \
	   +librt +libutp +zlib +LIBCURL_NOSSL:libmbedtls \
	   +LIBCURL_GNUTLS:libmbedtls +LIBCURL_MBEDTLS:libmbedtls
endef

define Package/transmission-daemon
  $(call Package/transmission/template)
  USERID:=transmission=224:transmission=224
endef

define Package/transmission-cli
  $(call Package/transmission/template)
  TITLE+= (utilities)
endef

define Package/transmission-remote
  $(call Package/transmission/template)
  TITLE+= (remote)
endef

define Package/transmission-web
  $(call Package/transmission/template)
  TITLE+= (webinterface)
  DEPENDS:=+transmission-daemon
  PKGARCH:=all
endef

define Package/transmission-daemon/description
 Transmission is a simple BitTorrent client.
 It features a very simple, intuitive interface
 on top on an efficient, cross-platform back-end.
 This package contains the daemon itself.
endef

define Package/transmission-cli/description
 CLI utilities for transmission.
endef

define Package/transmission-remote/description
 CLI remote interface for transmission.
endef

define Package/transmission-web/description
 Webinterface resources for transmission.
endef

define Package/transmission-daemon/conffiles
/etc/config/transmission
endef

TARGET_CFLAGS += -DHAVE_SIZE_T -latomic
TARGET_LDFLAGS += -Wl,--as-needed

CMAKE_OPTIONS += \
	-DENABLE_CLI:BOOL=YES \
	-DENABLE_GTK:BOOL=NO \
	-DENABLE_QT:BOOL=NO \
	-DENABLE_MAC:BOOL=NO \
	-DENABLE_TESTS:BOOL=NO \
	-DENABLE_NLS:BOOL=NO \
	-DENABLE_UTP:BOOL=YES \
	-DRUN_CLANG_TIDY:BOOL=NO \
	-DUSE_SYSTEM_EVENT2:BOOL=YES \
	-DUSE_SYSTEM_DEFLATE:BOOL=YES \
	-DUSE_SYSTEM_DHT:BOOL=YES \
	-DUSE_SYSTEM_MINIUPNPC:BOOL=YES \
	-DUSE_SYSTEM_NATPMP:BOOL=YES \
	-DUSE_SYSTEM_UTP:BOOL=YES \
	-DUSE_SYSTEM_B64:BOOL=YES \
	-DUSE_SYSTEM_PSL:BOOL=YES \
	-DWITH_INOTIFY:BOOL=YES \
	-DWITH_KQUEUE:BOOL=NO \
	-DWITH_SYSTEMD:BOOL=NO \
	-DB64_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	-DB64_LIBRARY=$(STAGING_DIR)/usr/lib/libb64.a \
	-DDHT_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	-DDHT_LIBRARY=$(STAGING_DIR)/usr/lib/libdht.so \
	-DUTP_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	-DUTP_LIBRARY=$(STAGING_DIR)/usr/lib/libutp.so \
	$(if $(CONFIG_LIBCURL_NOSSL),-DWITH_CRYPTO=mbedtls) \
	$(if $(CONFIG_LIBCURL_GNUTLS),-DWITH_CRYPTO=mbedtls) \
	$(if $(CONFIG_LIBCURL_MBEDTLS),-DWITH_CRYPTO=mbedtls) \
	$(if $(CONFIG_LIBCURL_OPENSSL),-DWITH_CRYPTO=openssl) \
	$(if $(CONFIG_LIBCURL_WOLFSSL),-DWITH_CRYPTO=wolfssl)

define Package/transmission-daemon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-daemon $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) files/transmission.init $(1)/etc/init.d/transmission
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/transmission.config $(1)/etc/config/transmission
	$(INSTALL_DIR) $(1)/etc/sysctl.d/
	$(INSTALL_CONF) files/transmission.sysctl $(1)/etc/sysctl.d/20-transmission.conf
	$(call InstallSeccomp,$(1),./files/transmission-daemon.json)
endef

define Package/transmission-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-cli \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-create \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-edit \
			$(PKG_INSTALL_DIR)/usr/bin/transmission-show \
			$(1)/usr/bin/
endef

define Package/transmission-remote/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/transmission-remote $(1)/usr/bin/
endef

define Package/transmission-web/install
	$(INSTALL_DIR) $(1)/usr/share/transmission
	$(CP) $(PKG_INSTALL_DIR)/usr/share/transmission/public_html $(1)/usr/share/transmission/
endef

$(eval $(call BuildPackage,transmission-daemon))
$(eval $(call BuildPackage,transmission-cli))
$(eval $(call BuildPackage,transmission-remote))
$(eval $(call BuildPackage,transmission-web))
