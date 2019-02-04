# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-jsonpath-ng
PKG_VERSION:=1.4.3
PKG_RELEASE:=1
PKG_MAINTAINER:=Karel Kočí <cynerd@email.cz>

PKG_SOURCE_URL:=https://pypi.python.org/packages/source/j/jsonpath-ng/
PKG_SOURCE:=jsonpath-ng-$(PKG_VERSION).tar.gz
PKG_HASH:=b1fc75b877e9b2f46845a455fbdcfb0f0d9c727c45c19a745d02db620a9ef0be
PKG_BUILD_DIR:=$(BUILD_DIR)/jsonpath-ng-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-jsonpath-ng
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/h2non/jsonpath-ng
  TITLE:=python3-jsonpath-ng
  DEPENDS:=+python3-ply +python3-six +python3-decorator
  VARIANT:=python3
endef

$(eval $(call Py3Package,python3-jsonpath-ng))
$(eval $(call BuildPackage,python3-jsonpath-ng))
$(eval $(call BuildPackage,python3-jsonpath-ng-src))
