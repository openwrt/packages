include $(TOPDIR)/rules.mk

PKG_NAME:=python3-attrs
PKG_VERSION:=19.1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=attrs-19.1.0.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/a/attrs/
PKG_HASH:=f0b870f674851ecbfbbbd364d6b5cbdff9dcedbc7f3f5e18a6891057f21fe399
PKG_BUILD_DIR:=$(BUILD_DIR)/attrs-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-attrs
  URL:=http://pypi.python.org/attrs
  DEPENDS:=+python3-light 
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	Classes Without Boilerplate
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))