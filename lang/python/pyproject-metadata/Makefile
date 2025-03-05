include $(TOPDIR)/rules.mk

PKG_NAME:=pyproject-metadata
PKG_VERSION:=0.7.1
PKG_RELEASE:=1

PYPI_NAME:=pyproject-metadata
PKG_HASH:=0a94f18b108b9b21f3a26a3d541f056c34edcb17dc872a144a15618fed7aef67

PKG_MAINTAINER:=Andy Syam <privasisource@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

HOST_BUILD_DEPENDS:=python3/host python-build/host python-installer/host python-wheel/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-pyproject-metadata
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=PEP 621 metadata parsing
  URL:=https://github.com/FFY00/python-pyproject-metadata
  DEPENDS:=+python3
endef

define Package/python3-pyproject-metadata/description
This project does not implement the parsing of pyproject.toml containing PEP 621 metadata.
Instead, given a Python data structure representing PEP 621 metadata (already parsed), it will validate this input and generate a PEP 643-compliant metadata file (e.g. PKG-INFO).
endef

$(eval $(call Py3Package,python3-pyproject-metadata))
$(eval $(call BuildPackage,python3-pyproject-metadata))
$(eval $(call BuildPackage,python3-pyproject-metadata-src))
$(eval $(call HostBuild))
