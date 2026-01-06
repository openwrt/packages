include $(TOPDIR)/rules.mk

PKG_NAME:=pigz
PKG_VERSION:=2.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://zlib.net/pigz
PKG_HASH:=eb872b4f0e1f0ebe59c9f7bd8c506c4204893ba6a8492de31df416f0d5170fd0

PKG_MAINTAINER:=Ken Wong <xinxijishuwyq@gmail.com>
PKG_LICENSE:=Zlib
PKG_LICENSE_FILES:=README
PKG_CPE_ID:=cpe:/a:zlib:pigz

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pigz
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Compression
  TITLE:=pigz
  URL:=https://zlib.net/pigz
  DEPENDS:=+zlib
endef

define Package/pigz/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pigz $(1)/usr/bin/pigz
endef

$(eval $(call BuildPackage,pigz))
