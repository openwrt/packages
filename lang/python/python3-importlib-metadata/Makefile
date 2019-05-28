include $(TOPDIR)/rules.mk

PKG_NAME:=python3-importlib-metadata
PKG_VERSION:=0.15
PKG_RELEASE:=1

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=importlib_metadata-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/i/importlib_metadata
PKG_HASH:=027cfc6524613de726789072f95d2e4cc64dd1dee8096d42d13f2ead5bd302f5
PKG_BUILD_DIR:=$(BUILD_DIR)/importlib_metadata-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-importlib-metadata
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Like importlib_resources only for metadata.
  URL:=https://gitlab.com/python-devs/importlib_metadata
  DEPENDS=+python3-light
  VARIANT:=python3
endef

define Package/python3-importlib-metadata/description
  importlib_metadata is a library to access the metadata for a Python package.
  It is intended to be ported to Python 3.8.
endef

$(eval $(call Py3Package,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-src))
