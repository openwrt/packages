include $(TOPDIR)/rules.mk

PKG_NAME:=catatonit
PKG_VERSION:=0.1.7
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/openSUSE/catatonit.git
PKG_SOURCE_DATE:=2022-03-07
PKG_SOURCE_VERSION:=d8d72fea155c144ed3bf298a35a1aba5625a5656
PKG_MIRROR_HASH:=5dfec105de2b1e674db55e12007aa66cf67769d38e3f294fbca54fc3e9b78674

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
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
