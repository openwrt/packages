include $(TOPDIR)/rules.mk

PKG_NAME:=fatresize
PKG_VERSION:=1.1.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ya-mouse/fatresize.git
PKG_SOURCE_DATE:=2021-11-24
PKG_SOURCE_VERSION:=316981e43b14f42a9aa7b461c97e1f61f6f2390b
PKG_MIRROR_HASH:=5a7eabaf5896a92c72b9bdf1cacc5aa1bd19335d8c617c8c9bd0f02699b91548

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/fatresize
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=fatresize
  SUBMENU:=Disc
  URL:=https://github.com/ya-mouse/fatresize
  DEPENDS:=+libparted
endef

define Package/fatresize/description
  Resize FAT partitions using libparted
endef

define Package/fatresize/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fatresize $(1)/sbin/
endef

$(eval $(call BuildPackage,fatresize))
