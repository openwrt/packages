include $(TOPDIR)/rules.mk

PKG_NAME:=initial-config-download
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <spooren@informatik.uni-leipzig.de>

include $(INCLUDE_DIR)/package.mk

define Package/initial-config-download
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=initial-config-download
  PKGARCH:=all
endef

Build/Compile=

define Package/initial-config-download/install
		$(INSTALL_DIR) $(1)/
		$(CP) -r files/* $(1)/
endef

$(eval $(call BuildPackage,initial-config-download))
