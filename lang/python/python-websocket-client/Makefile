include $(TOPDIR)/rules.mk

PKG_NAME:=python-websocket-client
PKG_VERSION:=1.4.1
PKG_RELEASE:=1

PYPI_NAME:=websocket-client
PKG_HASH:=f9611eb65c8241a67fb373bef040b3cf8ad377a9f6546a12b620b6511e8ea9ef

PKG_MAINTAINER:=Javier Marcet <javier@marcet.info>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-websocket-client
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=WebSocket client for Python. hybi13 is supported
  URL:=https://github.com/websocket-client/websocket-client
  DEPENDS:=+python3-light +python3-logging +python3-openssl
endef

define Package/python3-websocket-client/description
  websocket-client module is WebSocket client for python. This provide the low
  level APIs for WebSocket. All APIs are the synchronous functions.

  websocket-client supports only hybi-13.
endef

define Py3Package/python3-websocket-client/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/websocket/tests
endef

$(eval $(call Py3Package,python3-websocket-client))
$(eval $(call BuildPackage,python3-websocket-client))
$(eval $(call BuildPackage,python3-websocket-client-src))
