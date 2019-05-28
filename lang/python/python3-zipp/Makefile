include $(TOPDIR)/rules.mk

PKG_NAME:=python3-zipp
PKG_VERSION:=0.5.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=zipp-0.5.1.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/z/zipp/
PKG_HASH:=ca943a7e809cc12257001ccfb99e3563da9af99d52f261725e96dfe0f9275bc3
PKG_BUILD_DIR:=$(BUILD_DIR)/zipp-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-zipp
  URL:=http://pypi.python.org/zipp
  DEPENDS:=+python3-light 
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	Backport of pathlib-compatible object wrapper for zip files
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))