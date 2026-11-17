include $(TOPDIR)/rules.mk

PKG_NAME:=which
PKG_VERSION:=2.23
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/which
PKG_HASH:=a2c558226fc4d9e4ce331bd2fd3c3f17f955115d2c00e447618a4ef9978a2a73

PKG_MAINTAINER:=Huangbin Zhan <zhanhb88@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/which
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=which utility - full version
  URL:=https://carlowood.github.io/which/
  ALTERNATIVES:=300:/usr/bin/which:/usr/libexec/which-gnu
endef

define Package/which/description
 The which command shows the full pathname of a specified program, if the specified program is in your PATH.
endef

define Package/which/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/which $(1)/usr/libexec/which-gnu
endef

$(eval $(call BuildPackage,which))
