# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cachelib
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PYPI_NAME:=cachelib
PKG_HASH:=cc1856259f102c9273efa342100f70d9fafbd07b41ce05c501ee28e1dbbb5133

PKG_MAINTAINER:=Stepan Henek <stepan.henek@nic.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-cachelib
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=cachelib
  URL:=https://github.com/pallets/cachelib
  DEPENDS:=+python3-light
endef

define Package/python3-cachelib/description
  A collection of cache libraries in the same API interface.
  Extracted from werkzeug.
endef

$(eval $(call Py3Package,python3-cachelib))
$(eval $(call BuildPackage,python3-cachelib))
$(eval $(call BuildPackage,python3-cachelib-src))
