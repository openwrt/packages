include $(TOPDIR)/rules.mk

PKG_NAME:=libwslay
PKG_VERSION:=1.1.0
PKG_RELEASE=1

PKG_SOURCE:=release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/tatsuhiro-t/wslay/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=df5dca9f03614073cd8bdd22aa3c9b116f841ed3120b2d4463d2382cc44fc594

PKG_BUILD_DIR:=$(BUILD_DIR)/wslay-release-$(PKG_VERSION)

PKG_MAINTAINER:=James Taylor <james@jtaylor.id.au>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libwslay
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Wslay is a WebSocket library written in C
  URL:=https://tatsuhiro-t.github.io/wslay/
endef

define Package/libwslay/description
   Wslay is a WebSocket library written in C. It implements the protocol version 13 described
   in RFC 6455. This library offers 2 levels of API: event-based API and frame-based low-level
   API. For event-based API, it is suitable for non-blocking reactor pattern style. You can set
   callbacks in various events. For frame-based API, you can send WebSocket frame directly.
   Wslay only supports data transfer part of WebSocket protocol and does not perform opening
   handshake in HTTP.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/wslay
	$(CP) $(PKG_INSTALL_DIR)/usr/include/wslay/*.h $(1)/usr/include/wslay/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwslay.{a,so*} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libwslay.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libwslay/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libwslay.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwslay))
