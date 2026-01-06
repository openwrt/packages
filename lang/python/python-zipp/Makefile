include $(TOPDIR)/rules.mk

PKG_NAME:=python-zipp
PKG_VERSION:=3.16.2
PKG_RELEASE:=1

PYPI_NAME:=zipp
PKG_HASH:=ebc15946aa78bd63458992fc81ec3b6f7b1e92d51c35e6de1c3804e73b799147

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python-setuptools-scm/host  # setuptools_scm[toml] >= 3.4.1

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
