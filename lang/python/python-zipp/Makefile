include $(TOPDIR)/rules.mk

PKG_NAME:=python-zipp
PKG_VERSION:=3.23.0
PKG_RELEASE:=1

PYPI_NAME:=zipp
PKG_HASH:=a07157588a12518c9d4034df3fbbee09c814741a33ff63c05fa29d26a2404166

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools/host python-setuptools-scm/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zipp
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Zipfile object wrapper
  URL:=https://github.com/jaraco/zipp
  DEPENDS:=+python3-light +python3-urllib
endef

define Package/python3-zipp/description
  Backport of pathlib-compatible object wrapper for zip files
endef

$(eval $(call Py3Package,python3-zipp))
$(eval $(call BuildPackage,python3-zipp))
$(eval $(call BuildPackage,python3-zipp-src))
