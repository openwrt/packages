# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=Werkzeug
PKG_VERSION:=0.12.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/56/41/c095a77eb2dd69bf278dd664a97d3416af04e9ba1a00b8c138f772741d31/
PKG_HASH:=903a7b87b74635244548b30d30db4c8947fe64c5198f58899ddcd3a13c23bb26
PKG_BUILD_DEPENDS:=python python3
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-werkzeug
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://werkzeug.pocoo.org/
  TITLE:=python3-werkzeug
  DEPENDS:=+python3-light +python3-email
  VARIANT:=python3
endef

define Package/python3-werkzeug/description
Werkzeug

The Python WSGI Utility Library
endef

$(eval $(call Py3Package,python3-werkzeug))
$(eval $(call BuildPackage,python3-werkzeug))
