#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libmpdclient
PKG_VERSION:=2.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_HASH:=15fe693893c0d7ea3f4c35c4016fbd0332836164178b20983eec9b470846baf6
PKG_SOURCE_URL:=http://www.musicpd.org/download/libmpdclient/2/
PGK_HASH:=15fe693893c0d7ea3f4c35c4016fbd0332836164178b20983eec9b470846baf6

PKG_MAINTAINER:=Ted Hess <thess@kitschensync.net>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libmpdclient
    TITLE:=libmpdclient
    SECTION:=libs
    CATEGORY:=Libraries
    URL:=http://mpd.wikia.com/wiki/ClientLib:libmpdclient
endef

define Package/libmpdclient/description
    A stable, documented, asynchronous API library for interfacing MPD in the C, C++ & Objective C languages.
endef

TARGET_CFLAGS+="-std=gnu99"

define Build/Configure
	$(call Build/Configure/Default, \
		--disable-documentation \
	)
endef

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
