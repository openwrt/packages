include $(TOPDIR)/rules.mk

PKG_NAME:=python-zipp
PKG_VERSION:=2.2.0
PKG_RELEASE:=1

PYPI_NAME:=zipp
PKG_HASH:=5c56e330306215cd3553342cfafc73dda2c60792384117893f3a83f8a1209f50

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-zipp
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Zipfile object wrapper
  URL:=https://github.com/jaraco/zipp
  DEPENDS:=+python3-light +python3-more-itertools
  VARIANT:=python3
endef

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm

define Package/python3-zipp/description
  Backport of pathlib-compatible object wrapper for zip files
endef

$(eval $(call Py3Package,python3-zipp))
$(eval $(call BuildPackage,python3-zipp))
$(eval $(call BuildPackage,python3-zipp-src))
