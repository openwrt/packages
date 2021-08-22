include $(TOPDIR)/rules.mk

PKG_NAME:=xkeyboard-config
PKG_VERSION:=2.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.x.org/releases/individual/data/$(PKG_NAME)/
PKG_HASH:=91b18580f46b4e4ea913707f6c8d68ab5286879c3a6591462f3b9e760d3ac4d7

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=libxslt/host intltool/host perl-xml-parser/host

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += --disable-runtime-deps

define Package/xkeyboard-config
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=xkeyboard-config
  URL:=https://www.freedesktop.org/wiki/Software/XKeyboardConfig/
  DEPENDS:=+libxkbcommon $(INTL_DEPENDS)
endef

define Package/xkeyboard-config/description
  The non-arch keyboard configuration database for X Window.
endef

define Package/xkeyboard-config/install
	$(INSTALL_DIR) $(1)/usr/share/X11/xkb
	$(CP) $(PKG_INSTALL_DIR)/usr/share/X11/xkb/* $(1)/usr/share/X11/xkb/
endef

$(eval $(call BuildPackage,xkeyboard-config))
