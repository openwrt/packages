include $(TOPDIR)/rules.mk

PKG_NAME:=conmon
PKG_VERSION:=2.0.27
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containers/$(PKG_NAME)/archive/v$(PKG_VERSION)
PKG_HASH:=cb953fa418835a3f57af175df3641140d9c44ec219a7ad2efcc07952241f9ea5

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host meson/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include ../../devel/meson/meson.mk

define Package/conmon
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Podmon conmon
  URL:=https://podman.io
  DEPENDS:=+glib2 $(INTL_DEPENDS) $(ICONV_DEPENDS)
endef

define Package/conmon/description
  Podman: A tool for managing OCI containers and pods
endef

define Package/conmon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/podman/conmon $(1)/usr/bin
endef

$(eval $(call BuildPackage,conmon))
