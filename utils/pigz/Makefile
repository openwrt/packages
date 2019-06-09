# from https://zlib.net/pigz/
include $(TOPDIR)/rules.mk

PKG_NAME:=pigz
PKG_VERSION:=2.4
PKG_RELEASE:=4
PKG_BUILD_DIR:=$(BUILD_DIR)/pigz-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://zlib.net/pigz/
PKG_HASH:=a4f816222a7b4269bd232680590b579ccc72591f1bb5adafcd7208ca77e14f73
PKG_MAINTAINER:=
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pigz
  SUBMENU:=Compression
  TITLE:=pigz
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+zlib
  URL:=https://zlib.net/pigz
endef

define Package/pigz/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pigz $(1)/usr/bin/pigz
endef

$(eval $(call BuildPackage,pigz))

