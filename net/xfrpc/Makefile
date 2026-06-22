#
# Copyright (C) 2022 Dengfeng Liu
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=xfrpc
PKG_VERSION:=5.09.976
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/liudf0716/xfrpc/tar.gz/$(PKG_VERSION)?
PKG_HASH:=skip
PKG_BUILD_DIR:=$(BUILD_DIR)/xfrpc-$(PKG_VERSION)

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/xfrpc/config
  if PACKAGE_xfrpc
    config XFRPC_QUIC
      bool "Enable QUIC transport (ngtcp2 + nghttp3)"
      default n
      help
        Enable QUIC-based P2P transport for XTCP.
        Requires libngtcp2, libnghttp3, and a TLS crypto backend.
  endif
endef

define Package/xfrpc
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=C language fast reverse proxy client
  URL:=https://github.com/liudf0716/xfrpc
  DEPENDS:=+zlib +libjson-c +libevent2 +libevent2-openssl \
    +XFRPC_QUIC:libngtcp2 +XFRPC_QUIC:libnghttp3
endef

define Package/xfrpc/description
  xfrpc is C language fast reverse proxy client.
  Compare with golang version frpc, xfrpc can run in almost all OpenWrt devices.
  Supports TCP, HTTP, HTTPS, STCP, XTCP, SUDP, TCPMUX proxy types.
  Optional QUIC transport (ngtcp2) for both control and work connections.
  Features: TOML config (frp-compatible), AES-128-CFB use_encryption,
  health check, SIGHUP hot-reload, Unix Domain Socket proxy,
  TLS encryption, visitor support for STCP/XTCP P2P tunnels.
endef

define Package/xfrpc/conffiles
/etc/config/xfrpc
endef

CMAKE_OPTIONS += \
  -DENABLE_QUIC=$(if $(CONFIG_XFRPC_QUIC),ON,OFF) \
  -DUSE_WOLFSSL=OFF \
  -DDEBUG=ON

define Package/xfrpc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/xfrpc $(1)/usr/bin/xfrpc
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xfrpc.init $(1)/etc/init.d/xfrpc
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/xfrpc.conf $(1)/etc/config/xfrpc
endef

$(eval $(call BuildPackage,xfrpc))
