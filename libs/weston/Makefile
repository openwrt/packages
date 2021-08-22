include $(TOPDIR)/rules.mk

PKG_NAME:=weston
PKG_RELEASE:=$(AUTORELEASE)

#PKG_VERSION:=9.0.0
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
#PKG_SOURCE_URL:=https://wayland.freedesktop.org/releases/
#PKG_HASH:=5cf5d6ce192e0eb15c1fc861a436bf21b5bb3b91dbdabbdebe83e1f83aa098fe

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/wayland/weston.git
PKG_SOURCE_DATE:=2021-08-13
PKG_VERSION:=10.0.0~pre0-$(PKG_SOURCE_DATE)
PKG_SOURCE_VERSION:=d259bbeccdd321b5327537ddcdde06b8c5671d48
PKG_MIRROR_HASH:=45f6f7ff0a18f11222a09813064ef1a4bc6539eee4e73430d93ce38feea9c9cc

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host wayland/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/weston
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  TITLE:=weston
  URL:=https://wayland.freedesktop.org/
  DEPENDS:=+gstreamer1-plugins-base +libcairo +libevdev \
	+libgst1allocators +libgst1app +libgst1video +libgstreamer1 +libinput \
	+libmesa +libpango +libseat +libwayland +libwebp +libxkbcommon +pixman \
	+seatd +wayland-protocols +xkeyboard-config
endef

define Package/weston/description
endef

MESON_ARGS += \
	-Dlauncher-logind=false \
	-Dweston-launch=false \
	-Dlauncher-libseat=true \
	-Dbackend-drm=true \
	-Dbackend-drm-screencast-vaapi=false \
	-Dbackend-headless=false \
	-Dbackend-rdp=false \
	-Dbackend-x11=false \
	-Dxwayland=false \
	-Dcolor-management-lcms=false \
	-Dcolor-management-colord=false \
	-Dsystemd=false \
	-Dpipewire=false \
	-Dtest-gl-renderer=false \
	-Dtest-junit-xml=false \
	-Ddemo-clients=true \
	-Ddoc=false \
	-Dscanner_bin="$(STAGING_DIR_HOSTPKG)/bin/wayland-scanner"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig
endef

define Package/weston/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/libweston-10
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libweston-10/*.so* $(1)/usr/lib/libweston-10/
	$(INSTALL_DIR) $(1)/usr/lib/weston
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/weston/*.so* $(1)/usr/lib/weston/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/libexec
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/* $(1)/usr/libexec/
	$(INSTALL_DIR) $(1)/usr/share/libweston-10/protocols
	$(CP) $(PKG_INSTALL_DIR)/usr/share/libweston-10/protocols/* $(1)/usr/share/libweston-10/protocols/
	$(INSTALL_DIR) $(1)/usr/share/weston
	$(CP) $(PKG_INSTALL_DIR)/usr/share/weston/* $(1)/usr/share/weston/
endef

$(eval $(call BuildPackage,weston))
