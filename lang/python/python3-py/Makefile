include $(TOPDIR)/rules.mk

PKG_NAME:=python3-py
PKG_VERSION:=1.8.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT license
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=py-1.8.0.tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/py/
PKG_HASH:=dc639b046a6e2cff5bbe40194ad65936d6ba360b52b3c3fe1d08a82dd50b5e53
PKG_BUILD_DIR:=$(BUILD_DIR)/py-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/$(PKG_NAME)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=python3-py
  URL:=http://pypi.python.org/py
  DEPENDS:=+python3-light 
  VARIANT:=python3
endef

define Package/$(PKG_NAME)/description
	library with cross-python path, ini-parsing, io, code, log facilities
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))