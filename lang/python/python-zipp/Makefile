include $(TOPDIR)/rules.mk

PKG_NAME:=python-zipp
PKG_VERSION:=0.6.0
PKG_RELEASE:=2

PYPI_NAME:=zipp
PKG_HASH:=3718b1cbcd963c7d4c5511a8240812904164b7f381b647143a89d3b98f9bcd8e

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>, Jan Pavlinec <jan.pavlinec@nic.cz>
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
