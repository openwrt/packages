#
# Copyright (C) 2026 Daniel Golle <daniel@makrotopia.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libjuice
PKG_VERSION:=1.7.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/paullouisageneau/libjuice/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=86e075ca4732882746b6d5733ff1b6090f942e5750df58630b191b5f00f30010

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_FLAGS:=gc-sections lto
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libjuice
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=UDP Interactive Connectivity Establishment (ICE) library
  URL:=https://github.com/paullouisageneau/libjuice
  ABI_VERSION:=$(PKG_VERSION)
  DEPENDS:=+libpthread
endef

define Package/libjuice/description
  libjuice ("JUICE is a UDP Interactive Connectivity Establishment library")
  is a lightweight implementation of ICE (RFC 8445) in C, allowing to open
  a peer-to-peer UDP connection between two hosts behind NAT by hole
  punching, using STUN (RFC 8489) to gather reflexive candidates and
  optionally TURN (RFC 8656) to relay. It also provides a minimal
  STUN/TURN server implementation.
endef

CMAKE_OPTIONS += \
	-DNO_TESTS=ON \
	-DUSE_NETTLE=OFF

define Package/libjuice/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjuice.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libjuice))
