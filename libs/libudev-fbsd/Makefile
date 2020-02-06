# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libudev-fbsd
PKG_SOURCE_DATE:=2017-12-16
PKG_SOURCE_VERSION:=fa190fdf0b22a41b5f42e3a722f754c08ad7b337
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jiixyj/libudev-fbsd.git
PKG_MIRROR_HASH:=dac2d960191fe970c974f022d008ef3b712ad331e2426a51debd5aa2e208f02b

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libudev-fbsd
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=small udev shim for FreeBSD/devd (and other non-systemd)
  URL:=https://github.com/jiixyj/libudev-fbsd
  DEPENDS:=+libevdev
  PROVIDES:=libudev
  CONFLICTS:=libudev eudev udev
endef

define Package/libudev-fbsd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libudev-fbsd))
