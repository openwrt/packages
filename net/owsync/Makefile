# SPDX-License-Identifier: MIT

include $(TOPDIR)/rules.mk

PKG_NAME:=owsync
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/pgaufillet/owsync/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=3b92017e112ac8f1a45584b661757d6ec8f20d56ca7b0d9859d703de02ecac0e

PKG_MAINTAINER:=Pierre Gaufillet <pierre.gaufillet@bergamote.eu>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/owsync
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=Lightweight bidirectional file synchronization daemon
  URL:=https://github.com/pgaufillet/owsync
  DEPENDS:=+libjson-c +OWSYNC_ENABLE_ENCRYPTION:libopenssl +rpcd
endef

define Package/owsync/description
  owsync is a lightweight, secure, and robust high-availability file
  synchronization tool designed specifically for OpenWrt routers.
  It provides bi-directional, multi-master synchronization of
  configuration files between redundant nodes.
endef

define Package/owsync/config
  config OWSYNC_ENABLE_ENCRYPTION
    bool "Enable encryption support (AES-256-GCM)"
    default y
    help
      Build owsync with encryption support using OpenSSL.
      If disabled, owsync can only be used in plain mode over
      secure VPN connections (WireGuard/IPsec).
endef

MAKE_FLAGS += \
	PKGCONFIG="$(PKG_CONFIG)" \
	ENABLE_ENCRYPTION=$(if $(CONFIG_OWSYNC_ENABLE_ENCRYPTION),1,0)

define Package/owsync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/owsync $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/owsync.config $(1)/etc/config/owsync

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/owsync.init $(1)/etc/init.d/owsync

	$(INSTALL_DIR) $(1)/etc/owsync

	$(INSTALL_DIR) $(1)/usr/libexec/rpcd
	$(INSTALL_BIN) ./files/owsync.rpcd $(1)/usr/libexec/rpcd/owsync
endef

define Package/owsync/conffiles
/etc/config/owsync
/etc/owsync/
endef

define Package/owsync/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/owsync stop >/dev/null 2>&1
	/etc/init.d/owsync disable >/dev/null 2>&1
fi
exit 0
endef

$(eval $(call BuildPackage,owsync))
