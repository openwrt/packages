include $(TOPDIR)/rules.mk

PKG_NAME:=conmon
PKG_VERSION:=2.0.22
PKG_RELEASE:=3
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containers/$(PKG_NAME)/archive/v$(PKG_VERSION)
PKG_HASH:=41181db43c544cdd1a31aa851286e8c09a825879656f00f6adde431830893983

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

MAKE_VARS += PREFIX=/usr

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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/conmon $(1)/usr/bin
endef

$(eval $(call BuildPackage,conmon))
