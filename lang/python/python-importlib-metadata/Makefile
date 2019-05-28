include $(TOPDIR)/rules.mk

PKG_NAME:=python-importlib_metadata
PKG_VERSION:=0.19
PKG_RELEASE:=1

PKG_SOURCE:=importlib_metadata-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/i/importlib_metadata
PKG_HASH:=23d3d873e008a513952355379d93cbcab874c58f4f034ff657c7a87422fa64e8

PKG_BUILD_DIR:=$(BUILD_DIR)/importlib_metadata-$(PKG_VERSION)

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-importlib-metadata
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Read metadata from Python packages
  URL:=https://gitlab.com/python-devs/importlib_metadata
  DEPENDS=+python3-light +python3-zipp
  VARIANT:=python3
endef

PYTHON3_PKG_SETUP_VARS:= \
        PKG_VERSION="$(PKG_VERSION)"

define Package/python3-importlib-metadata/description
  importlib_metadata is a library to access the metadata for a Python package.
  It is intended to be ported to Python 3.8.
endef

$(eval $(call Py3Package,python3-importlib-metadata))
$(eval $(call BuildPackage,python3-importlib-metadata))
$(eval $(call BuildPackage,python3-importlib-metadata-src))
