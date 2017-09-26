include $(TOPDIR)/rules.mk

PKG_NAME:=netwhere
PKG_VERSION:=0.6
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=netwhere-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/benhsmith/netwhere/archive/$(PKG_VERSION)/
PKG_HASH:=0820cf5e59bf6b635c09a6282c664d6966b4d2887736b0f20937c86a8a03f563

PKG_BUILD_DEPENDS:=boost

PKG_MAINTAINER:=Ben Smith <le.ben.smith@gmail.com>

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/netwhere
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Netwhere
  MAINTAINER:=Ben Smith
  DEPENDS:=+libtins +libmicrohttpd
endef

define Package/netwhere/description
  Network monitor
endef

define Package/netwhere/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/netwhere $(1)/usr/bin/netwhere
	$(INSTALL_DIR) $(1)/www/netwhere
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/html/index.html $(1)/www/netwhere/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/html/netwhere.js $(1)/www/netwhere/
endef

$(eval $(call BuildPackage,netwhere))
