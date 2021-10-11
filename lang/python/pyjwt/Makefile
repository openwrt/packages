#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyjwt
PKG_VERSION:=2.2.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PYPI_NAME:=PyJWT
PKG_HASH:=a0b9a3b4e5ca5517cac9f1a6e9cd30bf1aa80be74fcdf4e28eded582ecfcfbae

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pyjwt
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=JSON Web Token implementation in Python
  URL:=http://github.com/jpadilla/pyjwt
  DEPENDS:=+python3
endef

define Package/python3-pyjwt/description
  A Python implementation of RFC 7519.
endef

$(eval $(call Py3Package,python3-pyjwt))
$(eval $(call BuildPackage,python3-pyjwt))
$(eval $(call BuildPackage,python3-pyjwt-src))
