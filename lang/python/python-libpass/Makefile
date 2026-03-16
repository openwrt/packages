# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=python-libpass
PKG_VERSION:=1.9.3
PKG_RELEASE:=1

PYPI_NAME:=libpass
PKG_HASH:=7830b9323d9ba96a841ad698a8dec1d43a2b0b7f1c855c76772e7972c1c6d959

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

PKG_BUILD_DEPENDS:=python-hatchling/host

define Package/python3-libpass
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Comprehensive password hashing framework
  URL:=https://github.com/notypecheck/passlib
  DEPENDS:=+python3
  PROVIDES:=python3-passlib
endef

define Package/python3-libpass/description
Libpass is a maintained fork of the now defunct Passlib package. Passlib
is a password hashing library for Python 2 & 3, which provides
cross-platform implementations of over 30 password hashing algorithms,
as well as a framework for managing existing password hashes. It’s
designed to be useful for a wide range of tasks, from verifying a hash
found in /etc/shadow, to providing full-strength password hashing for
multi-user applications.
endef

$(eval $(call Py3Package,python3-libpass))
$(eval $(call BuildPackage,python3-libpass))
$(eval $(call BuildPackage,python3-libpass-src))
