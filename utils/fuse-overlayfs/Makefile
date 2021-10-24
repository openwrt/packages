include $(TOPDIR)/rules.mk

PKG_NAME:=fuse-overlayfs
PKG_VERSION:=1.7.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containers/fuse-overlayfs/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=fe2c076aed7b8669e7970301a99c0b197759b611035d8199de4c0add7d2fb2b4

PKG_MAINTAINER:=W. Michael Petullo <mike@flyn.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fuse-overlayfs
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libfuse3
  TITLE:=fuse-overlayfs
  URL:=https://github.com/containers/fuse-overlayfs
endef

define Package/fuse-overlayfs/description
  FUSE overlay+shiftfs implementation for rootless containers
endef

define Package/fuse-overlayfs/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fuse-overlayfs $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fuse-overlayfs))
