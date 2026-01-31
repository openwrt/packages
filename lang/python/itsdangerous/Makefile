# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=itsdangerous
PKG_VERSION:=2.1.2
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=5dbbc68b317e5e42f327f9021763545dc3fc3bfe22e6deb96aaf1fc38874156a

PKG_MAINTAINER:=
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-itsdangerous
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=ItsDangerous
  URL:=https://palletsprojects.com/p/itsdangerous/
  DEPENDS:=+python3-light
endef

define Package/python3-itsdangerous/description
  Various helpers to pass trusted data to untrusted environments and back.
endef

$(eval $(call Py3Package,python3-itsdangerous))
$(eval $(call BuildPackage,python3-itsdangerous))
$(eval $(call BuildPackage,python3-itsdangerous-src))

