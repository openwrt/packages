#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-bcrypt
PKG_VERSION:=3.2.2
PKG_RELEASE:=1

PYPI_NAME:=bcrypt
PKG_HASH:=433c410c2177057705da2a9f2cd01dd157493b2a7ac14c8593a16b3dab6b6bfb

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libffi/host python-cffi/host  # cffi>=1.1

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-bcrypt
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern password hashing
  URL:=https://github.com/pyca/bcrypt/
  DEPENDS:=+python3-light +python3-cffi
endef

define Package/python3-bcrypt/description
  Good password hashing for your software and your servers.
endef

$(eval $(call Py3Package,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt-src))
