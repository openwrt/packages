#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bcrypt
PKG_VERSION:=3.1.5
PKG_RELEASE:=1

PKG_SOURCE:=bcrypt-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= https://files.pythonhosted.org/packages/source/b/$(PKG_NAME)
PKG_HASH:=136243dc44e5bab9b61206bd46fff3018bd80980b1a1dfbab64a22ff5745957f

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-bcrypt-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/bcrypt/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/pyca/bcrypt/
endef

define Package/python-bcrypt
$(call Package/bcrypt/Default)
  TITLE:=BCrypt
  DEPENDS+=+PACKAGE_python-bcrypt:python +PACKAGE_python-bcrypt:python-cffi \
	   +PACKAGE_python-bcrypt:python-six
  VARIANT:=python
endef

define Package/python3-bcrypt
$(call Package/bcrypt/Default)
  TITLE:=BCrypt
  DEPENDS+=+PACKAGE_python3-bcrypt:python3 +PACKAGE_python3-bcrypt:python3-cffi \
	   +PACKAGE_python3-bcrypt:python3-six
  VARIANT:=python3
endef

define Package/python-bcrypt/description
Good password hashing for your software and your servers
endef

define Package/python3-bcrypt/description
$(call Package/python-bcrypt/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-bcrypt))
$(eval $(call Py3Package,python3-bcrypt))

$(eval $(call BuildPackage,python-bcrypt))
$(eval $(call BuildPackage,python-bcrypt-src))
$(eval $(call BuildPackage,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt-src))
