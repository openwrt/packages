include $(TOPDIR)/rules.mk

PKG_NAME:=fuse-overlayfs
PKG_VERSION:=1.16
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/containers/fuse-overlayfs/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=45968517603389ead067222d234bc8d8ed33e4b4f8ba16216bdd3e6aedcccea9

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
