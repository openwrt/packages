include $(TOPDIR)/rules.mk

PKG_NAME:=kmscube
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-02-07
PKG_SOURCE_VERSION:=9f63f359fab1b5d8e862508e4e51c9dfe339ccb0
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/mesa/kmscube
PKG_MIRROR_HASH:=9b95a45789d81db6661be38d2c24181d7d90082edc5689225a6073d587f1235f

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=MIT

PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=meson/host

include $(INCLUDE_DIR)/package.mk
include ../../devel/meson/meson.mk

define Package/kmscube
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Video
  DEPENDS:=+glib2 +libmesa +libpng +gstreamer1-plugins-base +libgstreamer1 +libgst1allocators +libgst1video +libgst1app
  TITLE:=kmscube KMS/DRM/EGL example
  URL:=https://www.mesa3d.org
endef

define Package/kmscube/description
endef

define Package/kmscube/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
endef

$(eval $(call BuildPackage,kmscube))
