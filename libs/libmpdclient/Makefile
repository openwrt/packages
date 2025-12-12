#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmpdclient
PKG_VERSION:=2.22
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.musicpd.org/download/libmpdclient/2
PKG_HASH:=eac15b82b5ba5ed0648af580221eb74657394f7fe768e966d9e9ebb27435429f

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/libmpdclient
    TITLE:=libmpdclient
    SECTION:=libs
    CATEGORY:=Libraries
    URL:=https://musicpd.org/libs/libmpdclient/
endef

define Package/libmpdclient/description
    A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages.
endef

MESON_ARGS+=-Ddocumentation=false

define Build/InstallDev
	$(INSTALL_DIR) \
		$(1)/usr/include \
		$(1)/usr/lib \
		$(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/* \
		$(1)/usr/lib/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/* \
		$(1)/usr/include/
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig \
		$(1)/usr/lib/
endef

define Package/libmpdclient/install
	$(INSTALL_DIR) \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libmpdclient.so* \
		$(1)/usr/lib/
endef

$(eval $(call BuildPackage,libmpdclient))
