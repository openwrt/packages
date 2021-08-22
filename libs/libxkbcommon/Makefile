include $(TOPDIR)/rules.mk

PKG_NAME:=libxkbcommon
PKG_VERSION:=1.3.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://xkbcommon.org/download/
PKG_HASH:=7b09e098ea69bc3054f0c57a9a25fda571c4df22398811606e32b5fffeb75e7b

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause

PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=wayland

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

MESON_ARGS += \
	-Denable-x11=false \
	-Denable-docs=false \
	-Denable-wayland=true \
	-Dscanner_bin="$(STAGING_DIR_HOSTPKG)/bin/wayland-scanner"

define Package/libxkbcommon
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=libxkbcommon
  URL:=https://xkbcommon.org/
  DEPENDS:=+libwayland +libxml2 +wayland-protocols
endef

define Package/libxkbcommon/description
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libxkbcommon/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/libexec/xkbcommon
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/xkbcommon/* $(1)/usr/libexec/xkbcommon/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/xkbcli $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libxkbcommon))
