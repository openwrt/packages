include $(TOPDIR)/rules.mk

PKG_NAME:=python-importlib-metadata
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

PYPI_NAME:=importlib-metadata
PYPI_SOURCE_NAME:=importlib_metadata
PKG_HASH:=06f5b3a99029c7134207dd882428a66992a9de2bef7c2b699b5641f9886c3302

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>, Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm

define Package/python3-importlib-metadata
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Read metadata from Python packages
  URL:=https://gitlab.com/python-devs/importlib_metadata
  DEPENDS=+python3-light +python3-zipp
  VARIANT:=python3
endef

define Package/python3-importlib-metadata/description
  importlib_metadata is a library to access the metadata for a Python package.
endef

$(eval $(call Py3Package,python3-importlib-metadata))
$(eval $(call BuildPackage,python3-importlib-metadata))
$(eval $(call BuildPackage,python3-importlib-metadata-src))
