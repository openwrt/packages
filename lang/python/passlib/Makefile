# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=passlib
PKG_VERSION:=1.7.2
PKG_RELEASE:=1
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/passlib
PKG_HASH:=8d666cef936198bc2ab47ee9b0410c94adf2ba798e5a84bf220be079ae7ab6a8
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-passlib-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/passlib/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>
  TITLE:=Comprehensive password hashing framework
  URL:=https://bitbucket.org/ecollins/passlib
endef

define Package/python-passlib
$(call Package/passlib/Default)
  DEPENDS:=+PACKAGE_python-passlib:python +PACKAGE_python-passlib:python-dateutil
  VARIANT:=python
endef

define Package/python3-passlib
$(call Package/passlib/Default)
  DEPENDS:=+PACKAGE_python3-passlib:python3 +PACKAGE_python3-passlib:python3-dateutil
  VARIANT:=python3
endef

define Package/python-passlib/description
Passlib is a password hashing library for Python 2 & 3, which provides
cross-platform implementations of over 30 password hashing algorithms,
as well as a framework for managing existing password hashes. It’s
designed to be useful for a wide range of tasks, from verifying a hash
found in /etc/shadow, to providing full-strength password hashing for
multi-user applications.
endef

define Package/python3-passlib/description
$(call Package/python-passlib/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-passlib))
$(eval $(call Py3Package,python3-passlib))

$(eval $(call BuildPackage,python-passlib))
$(eval $(call BuildPackage,python-passlib-src))
$(eval $(call BuildPackage,python3-passlib))
$(eval $(call BuildPackage,python3-passlib-src))
