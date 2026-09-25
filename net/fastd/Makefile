#
# Copyright (C) 2012-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fastd
PKG_VERSION:=23

PKG_MAINTAINER:=Matthias Schiffer <mschiffer@universe-factory.net>
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/neocturne/fastd/releases/download/v$(PKG_VERSION)
PKG_HASH:=dcab54485c79dda22ce6308a2a48764d53977a518952facd1204ba21af1c86e0

PKG_LICENSE:=BSD-2-Clause LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYRIGHT src/dep/libmnl/COPYING
PKG_CPE_ID:=cpe:/a:fastd_project:fastd

PKG_CONFIG_DEPENDS:=\
	CONFIG_FASTD_ENABLE_METHOD_CIPHER_TEST \
	CONFIG_FASTD_ENABLE_METHOD_COMPOSED_GMAC \
	CONFIG_FASTD_ENABLE_METHOD_COMPOSED_UMAC \
	CONFIG_FASTD_ENABLE_METHOD_GENERIC_GMAC \
	CONFIG_FASTD_ENABLE_METHOD_GENERIC_POLY1305 \
	CONFIG_FASTD_ENABLE_METHOD_GENERIC_UMAC \
	CONFIG_FASTD_ENABLE_METHOD_NULL \
	CONFIG_FASTD_ENABLE_METHOD_NULL_L2TP \
	CONFIG_FASTD_ENABLE_CIPHER_NULL \
	CONFIG_FASTD_ENABLE_CIPHER_SALSA20 \
	CONFIG_FASTD_ENABLE_CIPHER_SALSA2012 \
	CONFIG_FASTD_ENABLE_MAC_GHASH \
	CONFIG_FASTD_ENABLE_MAC_UHASH \
	CONFIG_FASTD_WITH_CAPABILITIES \
	CONFIG_FASTD_WITH_CMDLINE_USER \
	CONFIG_FASTD_WITH_CMDLINE_LOGGING \
	CONFIG_FASTD_WITH_CMDLINE_OPERATION \
	CONFIG_FASTD_WITH_CMDLINE_COMMANDS \
	CONFIG_FASTD_WITH_DYNAMIC_PEERS \
	CONFIG_FASTD_WITH_STATUS_SOCKET \
	CONFIG_FASTD_WITH_OFFLOAD_L2TP


PKG_BUILD_DEPENDS:=nacl

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/fastd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+kmod-tun +libpthread +libuecc +FASTD_WITH_STATUS_SOCKET:libjson-c +FASTD_WITH_CAPABILITIES:libcap
  TITLE:=Fast and Secure Tunneling Daemon
  URL:=https://github.com/neocturne/fastd/
  SUBMENU:=VPN
endef

define Package/fastd/config
  source "$(SOURCE)/Config.in"
endef

feature = $(if $(CONFIG_FASTD_$(1)),enabled,disabled)

MESON_ARGS += \
	-Dcapabilities=$(call feature,WITH_CAPABILITIES) \
	-Dcipher_aes128-ctr=disabled \
	-Dcipher_null=$(call feature,ENABLE_CIPHER_NULL) \
	-Dcipher_salsa20=$(call feature,ENABLE_CIPHER_SALSA20) \
	-Dcipher_salsa2012=$(call feature,ENABLE_CIPHER_SALSA2012) \
	-Dcmdline_commands=$(call feature,WITH_CMDLINE_COMMANDS) \
	-Dcmdline_logging=$(call feature,WITH_CMDLINE_LOGGING) \
	-Dcmdline_operation=$(call feature,WITH_CMDLINE_OPERATION) \
	-Dcmdline_user=$(call feature,WITH_CMDLINE_USER) \
	-Ddynamic_peers=$(call feature,WITH_DYNAMIC_PEERS) \
	-Dmac_ghash=$(call feature,ENABLE_MAC_GHASH) \
	-Dmac_uhash=$(call feature,ENABLE_MAC_UHASH) \
	-Dmethod_cipher-test=$(call feature,ENABLE_METHOD_CIPHER_TEST) \
	-Dmethod_composed-gmac=$(call feature,ENABLE_METHOD_COMPOSED_GMAC) \
	-Dmethod_composed-umac=$(call feature,ENABLE_METHOD_COMPOSED_UMAC) \
	-Dmethod_generic-gmac=$(call feature,ENABLE_METHOD_GENERIC_GMAC) \
	-Dmethod_generic-poly1305=$(call feature,ENABLE_METHOD_GENERIC_POLY1305) \
	-Dmethod_generic-umac=$(call feature,ENABLE_METHOD_GENERIC_UMAC) \
	-Dmethod_null=$(call feature,ENABLE_METHOD_NULL) \
	-Dmethod_null_l2tp=$(call feature,ENABLE_METHOD_NULL_L2TP) \
	-Dstatus_socket=$(call feature,WITH_STATUS_SOCKET) \
	-Doffload_l2tp=$(call feature,WITH_OFFLOAD_L2TP) \
	-Dlibmnl_builtin=true \
	-Dsystemd=disabled \
	-Duse_nacl=true \
	-Db_lto=true \
	-Dprefix=/usr

define Package/fastd/description
Fast and secure tunneling daemon, which is optimized on small code size and few dependencies
endef

define Package/fastd/conffiles
/etc/config/fastd
endef

define Package/fastd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fastd $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/doc/examples/openwrt/fastd.init $(1)/etc/init.d/fastd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/doc/examples/openwrt/fastd.config $(1)/etc/config/fastd
	$(INSTALL_DIR) $(1)/etc/fastd
	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) files/fastd.upgrade $(1)/lib/upgrade/keep.d/fastd
endef

$(eval $(call BuildPackage,fastd))
