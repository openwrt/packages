include $(TOPDIR)/rules.mk

PKG_NAME:=libmanette
PKG_VERSION:=0.2.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNOME/$(PKG_NAME)/$(basename $(PKG_VERSION))
PKG_HASH:=48b349267180f1dc34d405a9e1e90ba16f054a19ce907930e679493d911ea1d8

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libmanette
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The simple GObject game controller library.
  URL:=https://gitlab.gnome.org/GNOME/libmanette
  DEPENDS:=+glib2 +libgudev +hidapi
endef

define Package/libmanette/description
 libmanette offers painless access to game controllers, from any programming
 language and with little dependencies.
endef

MESON_ARGS += \
	-Ddemos=true \
	-Dbuild-tests=true \
	-Dinstall-tests=true \
	-Ddoc=false \
	-Dintrospection=false \
	-Dvapi=false \
	-Dgudev=enabled

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/libmanette
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libmanette/*.h $(1)/usr/include/libmanette
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{a,so*} $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/libmanette/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libmanette))
