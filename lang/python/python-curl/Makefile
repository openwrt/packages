#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pycurl
PKG_VERSION:=7.43.0.2
PKG_RELEASE:=2

PKG_SOURCE:=pycurl-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/p/pycurl
PKG_HASH:=0f0cdfc7a92d4f2a5c44226162434e34f7d6967d3af416a6f1448649c09a25a4

PKG_MAINTAINER:=Waldemar Konik <informatyk74@interia.pl>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING-LGPL

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-curl-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-curl/Default
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Python
  TITLE:=Python module interface to the cURL library
  URL:=http://pycurl.io/
  DEPENDS:=+libcurl
endef

define Package/python-curl
$(call Package/python-curl/Default)
  DEPENDS+=+PACKAGE_python-curl:python
  VARIANT:=python
endef

define Package/python-curl/description
PycURL is a Python interface to libcurl, the multiprotocol file transfer library.
endef

define Package/python3-curl
$(call Package/python-curl/Default)
  DEPENDS+=+PACKAGE_python3-curl:python3
  VARIANT:=python3
endef

define Package/python3-curl/description
$(call Package/python-curl/description)
.
(Variant for Python3)
endef

PYTHON_PKG_SETUP_ARGS:=--with-mbedtls
PYTHON3_PKG_SETUP_ARGS:=--with-mbedtls

$(eval $(call PyPackage,python-curl))
$(eval $(call BuildPackage,python-curl))
$(eval $(call BuildPackage,python-curl-src))

$(eval $(call Py3Package,python3-curl))
$(eval $(call BuildPackage,python3-curl))
$(eval $(call BuildPackage,python3-curl-src))
