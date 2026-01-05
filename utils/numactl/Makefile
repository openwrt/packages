# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2026 Bootlin

include $(TOPDIR)/rules.mk

PKG_NAME:=numactl
PKG_VERSION:=2.0.19
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/numactl/numactl/releases/download/v$(PKG_VERSION)
PKG_HASH:=f2672a0381cb59196e9c246bf8bcc43d5568bc457700a697f1a1df762b9af884

PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>
PKG_LICENSE:=GPL-2.0 (libnuma), LGPL-2.1 (programs)
PKG_LICENSE_FILES:=LICENSE.GPL2 LICENSE.LGPL2.1

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/numactl/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/numactl/numactl
endef

define Package/libnuma
  TITLE:=libnuma
  ABI_VERSION:=1.0.0
  DEPENDS:= +libatomic
endef

define Package/numactl
  TITLE=numactl and other utilities
  DEPENDS:= +libnuma
endef

define Package/numactl/Default/description
Simple NUMA policy support. It consists of a numactl program to run other
programs with a specific NUMA policy and a libnuma to do allocations with NUMA
policy in applications.
endef

define Package/numactl/description
$(call Package/numactl/Default/description)

This package provides the binaries.
endef

define Package/libnuma/description
$(call Package/numactl/Default/description)

This package provides the libnuma library.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/numaif.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/numacompat1.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/numa.h $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnuma.so.$(ABI_VERSION) $(1)/usr/lib/
	$(LN) libnuma.so.$(ABI_VERSION) $(1)/usr/lib/libnuma.so.1
	$(LN) libnuma.so.$(ABI_VERSION) $(1)/usr/lib/libnuma.so
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libnuma.a $(1)/usr/lib/
endef

define Package/libnuma/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libnuma.so.$(ABI_VERSION) $(1)/usr/lib/
	$(LN) libnuma.so.$(ABI_VERSION) $(1)/usr/lib/libnuma.so.1
	$(LN) libnuma.so.$(ABI_VERSION) $(1)/usr/lib/libnuma.so
endef

define Package/numactl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/memhog $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/migratepages $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/migspeed $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/numactl $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/numademo $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/numastat $(1)/usr/bin
endef

$(eval $(call BuildPackage,libnuma))
$(eval $(call BuildPackage,numactl))
