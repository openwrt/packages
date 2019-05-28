include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pluggy
PKG_VERSION:=0.12.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT license
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=pluggy-0.12.0.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pluggy/
PKG_HASH:=0825a152ac059776623854c1543d65a4ad408eb3d33ee114dff91e57ec6ae6fc
PKG_BUILD_DIR:=$(BUILD_DIR)/pluggy-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-pluggy
  URL:=http://pypi.python.org/pluggy
  DEPENDS:=+python3-light 
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	plugin and hook calling mechanisms for python
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))