# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=vobject
PKG_VERSION:=0.9.6.1
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/v/vobject
PKG_HASH:=96512aec74b90abb71f6b53898dd7fe47300cc940104c4f79148f0671f790101
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-vobject-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-vobject/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>
  TITLE:=VObject
  URL:=http://eventable.github.io/vobject/
endef

define Package/python-vobject
$(call Package/python-vobject/Default)
  DEPENDS:=+PACKAGE_python-vobject:python +PACKAGE_python-vobject:python-dateutil
  VARIANT:=python
endef

define Package/python3-vobject
$(call Package/python-vobject/Default)
  DEPENDS:=+PACKAGE_python3-vobject:python3 +PACKAGE_python3-vobject:python3-dateutil
  VARIANT:=python3
endef

define Package/python-vobject/description
  vCard and vCalendar support for Python
endef

define Package/python3-vobject/description
$(call Package/python-vobject/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-vobject))
$(eval $(call BuildPackage,python-vobject))
$(eval $(call BuildPackage,python-vobject-src))
$(eval $(call Py3Package,python3-vobject))
$(eval $(call BuildPackage,python3-vobject))
$(eval $(call BuildPackage,python3-vobject-src))
