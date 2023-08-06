# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-contextlib2
PKG_VERSION:=21.6.0
PKG_RELEASE:=1

PYPI_NAME:=contextlib2
PKG_HASH:=ab1e2bfe1d01d968e1b7e8d9023bc51ef3509bba217bb730cee3827e1ee82869

PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>
PKG_LICENSE:=PSF-2.0 Apache-2.0
PKG_LICENSE_FILES:=LICENSE.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-contextlib2
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://contextlib2.readthedocs.org
  TITLE:=Backports and enhancements for the contextlib module
  DEPENDS:=+python3-light
endef

define Package/python-contextlib2/description
contextlib2 is a backport of the standard library's contextlib module to
earlier Python versions.
endef

$(eval $(call Py3Package,python3-contextlib2))
$(eval $(call BuildPackage,python3-contextlib2))
$(eval $(call BuildPackage,python3-contextlib2-src))
