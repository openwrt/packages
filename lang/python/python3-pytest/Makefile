include $(TOPDIR)/rules.mk

PKG_NAME:=python3-pytest
PKG_VERSION:=4.5.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT license
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=pytest-4.5.0.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pytest/
PKG_HASH:=1a8aa4fa958f8f451ac5441f3ac130d9fc86ea38780dd2715e6d5c5882700b24
PKG_BUILD_DIR:=$(BUILD_DIR)/pytest-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-pytest
  URL:=http://pypi.python.org/pytest
  DEPENDS:=+python3 +python3-py +python3-attrs +python3-six +python3-pluggy +python3-zipp +python3-more-itertools +python3-setuptools
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	pytest: simple powerful testing with Python
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
