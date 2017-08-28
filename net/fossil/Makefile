#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fossil
PKG_VERSION:=1.34
PKG_RELEASE:=2

PKG_LICENSE:=BSD-2-Clause
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)-src-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.fossil-scm.org/index.html/uv/download
PKG_HASH:=53a6b83e878feced9ac7705f87e5b6ea82727314e3e19202ae1c46c7e4dba49f

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-src-$(PKG_VERSION)

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fossil
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  TITLE:=Simple distributed software configuration management
  URL:=http://www.fossil-scm.org
  DEPENDS:=+zlib
endef

define Package/fossil/description
  Fossil is a distributed version control system, bug tracking system
  and wiki software server for use in software development.
endef

MAKE_FLAGS := \
	TCC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS) -I$(STAGING_DIR)/usr/include -DFOSSIL_ENABLE_JSON" \
	LDFLAGS="$(TARGET_LDFLAGS) -Wl,-rpath=$(TOOLCHAIN_DIR)/lib -L$(STAGING_DIR)/lib -L$(STAGING_DIR)/usr/lib -lm" \

define Build/Configure
endef

define Build/Compile
	$(call Build/Compile/Default, \
		-f Makefile.classic $(MAKE_FLAGS) all \
	)
endef

define Build/Install
endef

define Package/fossil/conffiles
/etc/config/fossil
endef

define Package/fossil/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/fossil.init $(1)/etc/init.d/fossil
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/fossil.config $(1)/etc/config/fossil
endef

$(eval $(call BuildPackage,fossil))
