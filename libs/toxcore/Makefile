#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=toxcore
PKG_VERSION:=0.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/irungentoo/toxcore.git
PKG_SOURCE_VERSION:=6d883f488ff59b2394982b62895d50b1d1d55bf4
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL

include $(INCLUDE_DIR)/package.mk

define Package/toxcore/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=Tox
  URL:=https://tox.im
endef

define Package/toxcore/description/Default
  Tox, a FOSS initiative, aims to be an easy to use, all-in-one
  communication platform that ensures their users full privacy and
  secure message delivery.
endef

define Package/libtoxcore
  $(call Package/toxcore/Default)
  DEPENDS:=+libsodium +librt +libpthread
  TITLE+= core library
endef

define Package/libtoxcore/description
  $(call Package/toxcore/description/Default)

  core library
endef

define Package/libtoxav
  $(call Package/toxcore/Default)
  DEPENDS:=+libtoxcore +libopus +libvpx
  TITLE+= A/V library
endef

define Package/libtoxav/description
  $(call Package/toxcore/description/Default)

  A/V library providing audio/video codec bindings
endef

define Package/libtoxdns
  $(call Package/toxcore/Default)
  DEPENDS:=+libtoxcore
  TITLE+= dns library
endef

define Package/libtoxdns/description
  $(call Package/toxcore/description/Default)

  DNS library
endef

define Package/libtoxencryptsave
  $(call Package/toxcore/Default)
  DEPENDS:=+libtoxcore
  TITLE+= encryptsave library
endef

define Package/libtoxencryptsave/description
  $(call Package/toxcore/description/Default)

  encryptsave library
endef

define Package/ntox
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  DEPENDS:=+libtoxcore +libncurses
  TITLE:=ntox Tox command-line client
endef

define Package/ntox/description
  $(call Package/toxcore/description/Default)

  nTox is an ncurses-based command-line client for Tox.
endef

define Package/tox-bootstrapd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Instant Messaging
  DEPENDS:=+libtoxcore +libconfig
  TITLE:=Tox DHT bootstrap
endef

define Package/tox-dht-bootstrap/description
  $(call Package/toxcore/description/Default)

  This package provide the Tox DHT bootstrap service.
endef

CONFIGURE_ARGS+= \
	--enable-daemon \
	--enable-ntox \
	--enable-av \
	--disable-testing \
	--disable-tests

define Package/libtoxav/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtoxav.*so* $(1)/usr/lib
endef

define Package/libtoxcore/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtoxcore.*so* $(1)/usr/lib
endef

define Package/libtoxdns/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtoxdns.*so* $(1)/usr/lib
endef

define Package/libtoxencryptsave/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtoxencryptsave.*so* $(1)/usr/lib
endef

define Package/tox-bootstrapd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tox-bootstrapd $(1)/usr/bin
endef

define Package/ntox/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nTox $(1)/usr/bin
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/tox
	$(CP) $(PKG_INSTALL_DIR)/usr/include/tox/*.h $(1)/usr/include/tox
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtox* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtoxcore.pc $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libtoxav))
$(eval $(call BuildPackage,libtoxcore))
$(eval $(call BuildPackage,libtoxdns))
$(eval $(call BuildPackage,libtoxencryptsave))
$(eval $(call BuildPackage,ntox))
$(eval $(call BuildPackage,tox-bootstrapd))
