include $(TOPDIR)/rules.mk

PKG_NAME:=catatonit
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/openSUSE/catatonit/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=d0cf1feffdc89c9fb52af20fc10127887a408bbd99e0424558d182b310a3dc92

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/catatonit
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=A container init that is so simple it's effectively brain-dead.
  URL:=https://github.com/openSUSE/catatonit
  DEPENDS:=
endef

define Package/catatonit/description
  This is a rewrite of initrs in C, because we found that it is not
  possible to statically compile Rust binaries without using musl.
  That was, in turn, a reimplementation of other container inits like
  tini and dumb-init.
endef

define Package/catatonit/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/catatonit $(1)/usr/bin/
endef

$(eval $(call BuildPackage,catatonit))
