include $(TOPDIR)/rules.mk

PKG_NAME:=harfbuzz
PKG_VERSION:=2.9.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/harfbuzz/harfbuzz/releases/download/2.9.0/
PKG_HASH:=3e1c2e1d2c65d56364fd16d1c41a06b2a35795496f78dfff635c2b7414b54c5a

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

MESON_ARGS += \
	-Dtests=disabled \
	-Ddocs=disabled \
	-Dbenchmark=disabled

define Package/harfbuzz
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=hafbuzz
  URL:=http://www.harfbuzz.org/
  DEPENDS:=+icu +libfreetype +glib2
endef

define Package/harfbuzz/description
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/harfbuzz/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,harfbuzz))
