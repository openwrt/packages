include $(TOPDIR)/rules.mk

PKG_NAME:=seatd
PKG_VERSION:=0.5.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.sr.ht/~kennylevinsen/seatd
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=9b899307e8717dc21735b02c80ebc91d6925c6bc5037f4a438d01258f472bc77

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host wayland/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/libseat
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=libseat
  URL:=https://git.sr.ht/~kennylevinsen/seatd
endef

define Package/libseat/description
endef

define Package/seatd
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=seatd
  URL:=https://git.sr.ht/~kennylevinsen/seatd
  DEPENDS:=+libseat
endef

define Package/seatd/description
endef

MESON_ARGS += \
	-Dlogind=disabled \
	-Dseatd=enabled \
	-Dbuiltin=disabled \
	-Dserver=enabled \
	-Dexamples=disabled \
	-Dman-pages=disabled \
	-Ddefaultpath="/tmp/run/seatd.sock"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/libseat/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so.* $(1)/usr/lib/
endef

define Package/seatd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/seatd $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libseat))
$(eval $(call BuildPackage,seatd))
$(eval $(call HostBuild))
