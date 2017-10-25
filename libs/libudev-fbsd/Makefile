# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libudev-fbsd

PKG_RELEASE:=2
PKG_VERSION:=20160820
PKG_SOURCE_VERSION:=1f21323b817e70253d3c04bc8bedd61c477d0544

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_MIRROR_HASH:=cc885851c97dcaef65d7f4fb0899ed1a01412b02e44851476ac47ce4da024d0b
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/jiixyj/libudev-fbsd.git

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_INSTALL:=1

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

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/libudev-fbsd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libudev-fbsd))
