#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pyjwt
PKG_VERSION:=1.7.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=PyJWT-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/P/PyJWT
PKG_HASH:=8d59a976fb773f3e6a39c85636357c4f0e242707394cadadd9814f5cbaa20e96

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-PyJWT-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-pyjwt/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=JSON Web Token implementation in Python
  URL:=http://github.com/jpadilla/pyjwt
endef

define Package/python-pyjwt
  $(call Package/python-pyjwt/Default)
  DEPENDS:=+PACKAGE_python-pyjwt:python
  VARIANT:=python
endef

define Package/python3-pyjwt
  $(call Package/python-pyjwt/Default)
  DEPENDS:=+PACKAGE_python3-pyjwt:python3
  VARIANT:=python3
endef

define Package/python-pyjwt/description
  A Python implementation of RFC 7519.
endef

define Package/python3-pyjwt/description
$(call Package/python-pyjwt/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-pyjwt))
$(eval $(call BuildPackage,python-pyjwt))
$(eval $(call BuildPackage,python-pyjwt-src))

$(eval $(call Py3Package,python3-pyjwt))
$(eval $(call BuildPackage,python3-pyjwt))
$(eval $(call BuildPackage,python3-pyjwt-src))
