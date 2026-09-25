include $(TOPDIR)/rules.mk

PKG_NAME:=python-fnvhash
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PYPI_NAME:=fnvhash
PKG_HASH:=3e82d505054f9f3987b2b5b649f7e7b6f48349f6af8a1b8e4d66779699c85a8e

PKG_MAINTAINER:=Timothy Ace <openwrt@timothyace.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-fnvhash
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pure Python FNV hash implementation
  URL:=https://github.com/znerol/py-fnvhash
  DEPENDS:=+python3-light
endef

define Package/python3-fnvhash/description
Pure Python implementation of the FNV hash family with 100% test coverage.
endef

$(eval $(call Py3Package,python3-fnvhash))
$(eval $(call BuildPackage,python3-fnvhash))
$(eval $(call BuildPackage,python3-fnvhash-src))
