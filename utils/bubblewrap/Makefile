include $(TOPDIR)/rules.mk

PKG_NAME:=bubblewrap
PKG_VERSION:=0.11.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/containers/$(PKG_NAME)/releases/download/v$(PKG_VERSION)
PKG_HASH:=69abc30005d2186baf7737feacd8da35633b93cf5af38838ecff17c5f8e924f6

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=LGPLv2-or-later
PKG_CPE_ID:=cpe:/a:projectatomic:bubblewrap

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
