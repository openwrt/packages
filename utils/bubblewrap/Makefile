include $(TOPDIR)/rules.mk

PKG_NAME:=bubblewrap
PKG_VERSION:=0.11.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/containers/$(PKG_NAME)/releases/download/v$(PKG_VERSION)
PKG_HASH:=988fd6b232dafa04b8b8198723efeaccdb3c6aa9c1c7936219d5791a8b7a8646

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPLv2-or-later

PKG_FORTIFY_SOURCE:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

MESON_ARGS += \
	-Dbash_completion=disabled \
	-Dman=disabled \
	-Dselinux=disabled \
	-Dtests=false \
	-Dzsh_completion=disabled

define Package/bubblewrap
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Bubblewrap sandbox
  URL:=https://github.com/containers/bubblewrap
  DEPENDS:=+libcap
endef

define Package/bubblewrap/description
 Bubblewrap is a container tool for security sandboxes.
endef

define Package/bubblewrap/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/bwrap $(1)/usr/bin
endef

$(eval $(call BuildPackage,bubblewrap))
