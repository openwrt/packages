#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stress-ng
PKG_VERSION:=0.13.01
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://kernel.ubuntu.com/~cking/tarballs/stress-ng
PKG_HASH:=f37f739e4d15343360a47980b67dc8b2a6bf3d4d3ef727d55e2dd99a0b64f9ea

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/stress-ng
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=stress-ng is a stress test utility
  URL:=https://kernel.ubuntu.com/~cking/stress-ng/
  DEPENDS:=+zlib +libbsd +libaio +libsctp +libkmod
endef

define Package/stress-ng/description
stress-ng will stress test a computer system in various selectable ways. It
was designed to exercise various physical subsystems of a computer as well as
the various operating system kernel interfaces.
endef

define Package/stress-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stress-ng $(1)/usr/bin/
endef

$(eval $(call BuildPackage,stress-ng))
