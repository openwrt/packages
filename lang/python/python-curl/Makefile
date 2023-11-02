#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pycurl
PKG_VERSION:=7.45.2
PKG_RELEASE:=3

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=5730590be0271364a5bddd9e245c9cc0fb710c4cbacbdd95264a3122d23224ca

PKG_MAINTAINER:=Waldemar Konik <informatyk74@interia.pl>
PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING-LGPL

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-curl
  CATEGORY:=Languages
  SECTION:=lang
  SUBMENU:=Python
  TITLE:=Python module interface to the cURL library
  URL:=http://pycurl.io/
  DEPENDS:=+libcurl +python3
endef

define Package/python3-curl/description
PycURL is a Python interface to libcurl, the multiprotocol file transfer library.
endef

ifdef CONFIG_LIBCURL_OPENSSL
  PYTHON3_PKG_BUILD_VARS:=PYCURL_SSL_LIBRARY=openssl
endif

ifdef CONFIG_LIBCURL_GNUTLS
  PYTHON3_PKG_BUILD_VARS:=PYCURL_SSL_LIBRARY=gnutls
endif

ifdef CONFIG_LIBCURL_MBEDTLS
  PYTHON3_PKG_BUILD_VARS:=PYCURL_SSL_LIBRARY=mbedtls
endif

ifdef CONFIG_LIBCURL_WOLFSSL
  PYTHON3_PKG_BUILD_VARS:=PYCURL_SSL_LIBRARY=wolfssl
endif

$(eval $(call Py3Package,python3-curl))
$(eval $(call BuildPackage,python3-curl))
$(eval $(call BuildPackage,python3-curl-src))
