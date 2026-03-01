# SPDX-License-Identifier: GPL-2.0-or-later
#
# Copyright (C) 2025 Liu Yu <f78fk@live.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=dnssec-check
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/liuyuf78fk/$(PKG_NAME)/releases/download/v$(PKG_VERSION)
PKG_HASH:=8416d2616b58d413fdeb3f5a2f52e7e6a9e3e347b32f4085ee31484ec34e3625

PKG_MAINTAINER:=Liu Yu <f78fk@live.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/dnssec-check
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Simple DNSSEC validation tool
  DEPENDS:=+libuci +bind-dig
  URL:=https://github.com/liuyuf78fk/dnssec-check
endef

define Package/dnssec-check/description
 Checks whether the system's DNS resolution path properly supports DNSSEC validation.
 Reports the DNSSEC support level as secure, medium, or insecure based on resolver behavior.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) \
	-o $(PKG_BUILD_DIR)/dnssec-check \
	$(PKG_BUILD_DIR)/dnssec-check.c -luci
endef

define Package/dnssec-check/conffiles
/etc/config/dnssec-check
endef

define Package/dnssec-check/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnssec-check $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config/dnssec-check $(1)/etc/config/dnssec-check
endef

$(eval $(call BuildPackage,dnssec-check))
