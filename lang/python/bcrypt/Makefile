#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=bcrypt
PKG_VERSION:=3.1.7
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=0b0069c752ec14172c5f78208f1863d7ad6755a6fae6fe76ec2c80d13be41e42

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libffi/host
HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="cffi>=1.1"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi>=1.1"

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/bcrypt/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Modern password hashing
  URL:=https://github.com/pyca/bcrypt/
endef

define Package/python-bcrypt
$(call Package/bcrypt/Default)
  DEPENDS:= \
	+PACKAGE_python-bcrypt:python \
	+PACKAGE_python-bcrypt:python-cffi \
	+PACKAGE_python-bcrypt:python-six
  VARIANT:=python
endef

define Package/python3-bcrypt
$(call Package/bcrypt/Default)
  DEPENDS:= \
	+PACKAGE_python3-bcrypt:python3 \
	+PACKAGE_python3-bcrypt:python3-cffi \
	+PACKAGE_python3-bcrypt:python3-six
  VARIANT:=python3
endef

define Package/python-bcrypt/description
  Good password hashing for your software and your servers.
endef

define Package/python3-bcrypt/description
$(call Package/python-bcrypt/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-bcrypt))
$(eval $(call BuildPackage,python-bcrypt))
$(eval $(call BuildPackage,python-bcrypt-src))

$(eval $(call Py3Package,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt))
$(eval $(call BuildPackage,python3-bcrypt-src))
