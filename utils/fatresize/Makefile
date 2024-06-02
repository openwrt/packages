include $(TOPDIR)/rules.mk

PKG_NAME:=fatresize
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ya-mouse/fatresize.git
PKG_SOURCE_DATE:=2023-06-11
PKG_SOURCE_VERSION:=ab78c48fe46d0eb29fcdfa3c6586ade223218433
PKG_MIRROR_HASH:=61797f8316f757b1bc54c2ca349ab50ae3750cadfd9dcaa2a5f37bbdf306d03a

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
