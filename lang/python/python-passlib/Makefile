# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-passlib
PKG_VERSION:=1.7.4
PKG_RELEASE:=1

PYPI_NAME:=passlib
PKG_HASH:=defd50f72b65c5402ab2c573830a6978e5f202ad0d984793c8dde2c4152ebe04

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-passlib
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Comprehensive password hashing framework
  URL:=https://passlib.readthedocs.io/
  DEPENDS:=+python3
endef

define Package/python3-passlib/description
Passlib is a password hashing library for Python 2 & 3, which provides
cross-platform implementations of over 30 password hashing algorithms,
as well as a framework for managing existing password hashes. It’s
designed to be useful for a wide range of tasks, from verifying a hash
found in /etc/shadow, to providing full-strength password hashing for
multi-user applications.
endef

$(eval $(call Py3Package,python3-passlib))
$(eval $(call BuildPackage,python3-passlib))
$(eval $(call BuildPackage,python3-passlib-src))
