#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pycurl
PKG_VERSION:=7.43.0.3
PKG_RELEASE:=1

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=6f08330c5cf79fa8ef68b9912b9901db7ffd34b63e225dce74db56bb21deda8e

PKG_MAINTAINER:=Waldemar Konik <informatyk74@interia.pl>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING-LGPL

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

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

PYTHON_PKG_SETUP_ARGS:=
PYTHON3_PKG_SETUP_ARGS:=

ifdef CONFIG_LIBCURL_OPENSSL
  PYTHON_PKG_SETUP_ARGS+=--with-openssl
  PYTHON3_PKG_SETUP_ARGS+=--with-openssl
endif

ifdef CONFIG_LIBCURL_GNUTLS
  PYTHON_PKG_SETUP_ARGS+=--with-gnutls
  PYTHON3_PKG_SETUP_ARGS+=--with-gnutls
endif

ifdef CONFIG_LIBCURL_MBEDTLS
  PYTHON_PKG_SETUP_ARGS+=--with-mbedtls
  PYTHON3_PKG_SETUP_ARGS+=--with-mbedtls
endif

ifdef CONFIG_LIBCURL_WOLFSSL
  PYTHON_PKG_SETUP_ARGS+=--with-wolfssl
  PYTHON3_PKG_SETUP_ARGS+=--with-wolfssl
endif

$(eval $(call PyPackage,python-curl))
$(eval $(call BuildPackage,python-curl))
$(eval $(call BuildPackage,python-curl-src))

$(eval $(call Py3Package,python3-curl))
$(eval $(call BuildPackage,python3-curl))
$(eval $(call BuildPackage,python3-curl-src))
