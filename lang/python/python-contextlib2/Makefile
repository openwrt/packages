# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-contextlib2
PKG_VERSION:=0.5.5
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PYPI_NAME:=contextlib2
PKG_HASH:=509f9419ee91cdd00ba34443217d5ca51f5a364a404e1dce9e8979cea969ca48

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-contextlib2
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://contextlib2.readthedocs.org
  TITLE:=python3-contextlib2
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python-contextlib2/description
  contextlib2 is a backport of the standard library’s contextlib module to earlier Python versions.
endef

$(eval $(call Py3Package,python3-contextlib2))
$(eval $(call BuildPackage,python3-contextlib2))
$(eval $(call BuildPackage,python3-contextlib2-src))
