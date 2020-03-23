include $(TOPDIR)/rules.mk

PKG_NAME:=python-zipp
PKG_VERSION:=3.1.0
PKG_RELEASE:=1

PYPI_NAME:=zipp
PKG_HASH:=c599e4d75c98f6798c509911d08a22e6c021d074469042177c8c86fb92eefd96

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
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="setuptools_scm[toml] >= 3.4.1"

define Package/python3-zipp/description
  Backport of pathlib-compatible object wrapper for zip files
endef

$(eval $(call Py3Package,python3-zipp))
$(eval $(call BuildPackage,python3-zipp))
$(eval $(call BuildPackage,python3-zipp-src))
