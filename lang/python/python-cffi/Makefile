#
# Copyright (C) 2015-2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-cffi
PKG_VERSION:=1.11.4
PKG_RELEASE:=1

PKG_SOURCE:=cffi-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/10/f7/3b302ff34045f25065091d40e074479d6893882faef135c96f181a57ed06
PKG_HASH:=df9083a992b17a28cd4251a3f5c879e0198bb26c9e808c4647e0a18739f1d11d

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-cffi-$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>, Alexandru Ardelean <ardeleanalex@gmail.com>

PKG_BUILD_DEPENDS:=libffi/host

HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-cffi/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://cffi.readthedocs.org/
  DEPENDS:=+libffi
endef

define Package/python-cffi
$(call Package/python-cffi/Default)
  TITLE:=python-cffi
  DEPENDS+=+PACKAGE_python-cffi:python-light +PACKAGE_python-cffi:python-pycparser
  VARIANT:=python
endef

define Package/python3-cffi
$(call Package/python-cffi/Default)
  TITLE:=python3-cffi
  DEPENDS+=+PACKAGE_python3-cffi:python3-light +PACKAGE_python3-cffi:python3-pycparser
  VARIANT:=python3
endef

define Package/python-cffi/description
Foreign Function Interface for Python calling C code.
endef

define Package/python3-cffi/description
$(call Package/python-cffi/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-cffi))
$(eval $(call BuildPackage,python-cffi))
$(eval $(call BuildPackage,python-cffi-src))

$(eval $(call Py3Package,python3-cffi))
$(eval $(call BuildPackage,python3-cffi))
$(eval $(call BuildPackage,python3-cffi-src))
