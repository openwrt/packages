include $(TOPDIR)/rules.mk

PKG_NAME:=pigz
PKG_VERSION:=2.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://zlib.net/pigz
PKG_HASH:=b4c9e60344a08d5db37ca7ad00a5b2c76ccb9556354b722d56d55ca7e8b1c707

PKG_MAINTAINER:=Ken Wong <xinxijishuwyq@gmail.com>
PKG_LICENSE:=CUSTOM
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

