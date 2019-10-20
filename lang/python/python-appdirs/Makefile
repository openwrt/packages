# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-appdirs
PKG_VERSION:=1.4.3
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PYPI_NAME:=appdirs
PKG_HASH:=9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92
PKG_LICENSE:=MIT

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-appdirs
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/ActiveState/appdirs
  TITLE:=python3-appdirs
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python-appdirs/description
  The Universal Character Encoding Detector
endef

$(eval $(call Py3Package,python3-appdirs))
$(eval $(call BuildPackage,python3-appdirs))
$(eval $(call BuildPackage,python3-appdirs-src))
