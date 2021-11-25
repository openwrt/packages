include $(TOPDIR)/rules.mk

PKG_NAME:=libslirp
PKG_VERSION:=4.6.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/slirp/$(PKG_NAME)/-/archive/v$(PKG_VERSION)
PKG_HASH:=69ad4df0123742a29cc783b35de34771ed74d085482470df6313b6abeb799b11

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmailcom>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk
include $(INCLUDE_DIR)/nls.mk

define Package/libslirp
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Networking
  TITLE:=user-mode networking library for virtual environments
  DEPENDS:=+glib2
  URL:=https://gitlab.freedesktop.org/slirp/libslirp
endef

define Package/libslirp/description
  libslirp is a user-mode networking library used by virtual machines,
  containers or various tools.
endef

define Package/libslirp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslirp.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslirp.so.* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/include/slirp $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslirp.so $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libslirp.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/slirp/** $(1)/usr/include/slirp/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/** $(1)/usr/lib/pkgconfig/
endef

$(eval $(call BuildPackage,libslirp))
