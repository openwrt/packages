# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=itsdangerous
PKG_VERSION:=2.2.0
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=e0050c0b7da1eea53ffaf149c0cfbb5c6e2e2b69c4bef22c81fa6eb73e5f6173

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
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

