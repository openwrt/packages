#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=valkey
PKG_VERSION:=9.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/valkey-io/valkey/archive/refs/tags/$(PKG_VERSION).tar.gz?
PKG_HASH:=9cfbc5f32a2a6058ee0f8c532b9c4d24167cc49d719f091dd75f1bb8353a1fc5

PKG_MAINTAINER:=Matthew Cather <mattbob4@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:lfprojects:valkey

PKG_FORTIFY_SOURCE:=0
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/valkey/Default
  SUBMENU:=Database
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://valkey.io/
endef

define Package/valkey-server
$(call Package/valkey/Default)
  TITLE:=Valkey in-memory key-value data store (server)
  DEPENDS:=+libpthread +libatomic
endef

define Package/valkey-server/description
  Valkey is an open source (BSD) high-performance key/value datastore
  that supports a variety of workloads such as caching, message queues,
  and can act as a primary database. This package contains the Valkey server.
endef

define Package/valkey-cli
$(call  Package/valkey/Default)
  TITLE:=Valkey in-memory key-value data store (CLI client)
  DEPENDS:=+libatomic
endef

define Package/valkey-cli/description
  Valkey is an open source (BSD) high-performance key/value datastore.
  This package contains the Valkey CLI client.
endef

define Package/valkey-utils
$(call  Package/valkey/Default)
  TITLE:=Valkey in-memory key-value data store (utilities)
  DEPENDS:=+valkey-server
endef

define Package/valkey-utils/description
  Valkey is an open source (BSD) high-performance key/value datastore.
  This package contains Valkey utilities (valkey-benchmark, valkey-check-aof,
  valkey-check-rdb).
endef

MAKE_FLAGS+= \
	MALLOC="libc" \
	USE_JEMALLOC="no" \
	PREFIX="$(PKG_INSTALL_DIR)/usr" \
	ARCH=""

TARGET_LDFLAGS += -latomic

define Package/valkey-server/conffiles
/etc/valkey/valkey.conf
/etc/config/valkey
endef

define Package/valkey-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/valkey-server $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/valkey
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/valkey.conf $(1)/etc/valkey/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/valkey.init $(1)/etc/init.d/valkey
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/valkey.config $(1)/etc/config/valkey
endef

define Package/valkey-cli/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/valkey-cli $(1)/usr/bin/
endef

define Package/valkey-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/valkey-benchmark $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/valkey-check-aof $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/valkey-check-rdb $(1)/usr/bin/
endef

$(eval $(call BuildPackage,valkey-server))
$(eval $(call BuildPackage,valkey-cli))
$(eval $(call BuildPackage,valkey-utils))
