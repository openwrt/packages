# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libudev-zero
PKG_VERSION:=1.0.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/illiliti/libudev-zero/tar.gz/$(PKG_VERSION)?
PKG_HASH:=0bd89b657d62d019598e6c7ed726ff8fed80e8ba092a83b484d66afb80b77da5

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libudev-zero
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Drop-in replacement for libudev
  URL:=https://github.com/illiliti/libudev-zero
  DEPENDS:=+libevdev
  PROVIDES:=libudev
  CONFLICTS:=libudev eudev udev
endef

MAKE_FLAGS += \
	PREFIX=/usr

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libudev.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libudev.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libudev.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libudev-zero/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libudev.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libudev-zero))
