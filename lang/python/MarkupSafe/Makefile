# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=MarkupSafe
PKG_VERSION:=2.1.0
PKG_RELEASE:=$(AUTORELEASE)

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=80beaf63ddfbc64a0452b841d8036ca0611e049650e20afcb882f5d3c266d65f

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-markupsafe
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=MarkupSafe
  URL:=https://palletsprojects.com/p/markupsafe/
  DEPENDS:=+python3-light
endef

define Package/python3-markupsafe/description
  MarkupSafe implements a text object that escapes characters so it is safe to use in HTML and XML.
endef

$(eval $(call Py3Package,python3-markupsafe))
$(eval $(call BuildPackage,python3-markupsafe))
$(eval $(call BuildPackage,python3-markupsafe-src))
