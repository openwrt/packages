#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gunicorn
PKG_VERSION:=19.9.0
PKG_RELEASE=2

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=fa2662097c66f920f53f70621c6c58ca4a3c4d3434205e608e121b5b3b71f4f3

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/gunicorn/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=WSGI HTTP Server for UNIX
  URL:=https://gunicorn.org
endef

define Package/python-gunicorn
$(call Package/gunicorn/Default)
  DEPENDS:=+python
  VARIANT:=python
endef

define Package/python-gunicorn/description
    WSGI HTTP Server for UNIX (libraries)
endef

define PyPackage/python-gunicorn/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/gunicorn/workers/_gaiohttp.py
endef

define Package/python3-gunicorn
$(call Package/gunicorn/Default)
  DEPENDS:=+python3
  VARIANT:=python3
endef

define Package/python3-gunicorn/description
$(call Package/python-gunicorn/description)
.
(Variant for Python3)
endef

# Make sure that the binaries are not installed with the libraries
# That means adding some empty Py[3]Package/gunicorn[3]/install rules
define PyPackage/python-gunicorn/install
	:
endef

define Py3Package/python3-gunicorn/install
	:
endef

define Package/gunicorn
$(call Package/gunicorn/Default)
  DEPENDS:=+python +python-pkg-resources +python-gunicorn
endef

define Package/gunicorn/description
    WSGI HTTP Server for UNIX (daemon)
endef

define Package/gunicorn/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(call PyShebang,$(1)/usr/bin/*)
endef

define Package/gunicorn3
$(call Package/gunicorn/Default)
  DEPENDS:=+python3 +python3-pkg-resources +python3-gunicorn
endef

define Package/gunicorn3/description
$(call Package/gunicorn/description)
.
(Variant for Python3)
endef

define Package/gunicorn3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/gunicorn \
		$(1)/usr/bin/gunicorn3
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/gunicorn_paster \
		$(1)/usr/bin/gunicorn3_paster
	$(call Py3Shebang,$(1)/usr/bin/*)
endef

$(eval $(call PyPackage,python-gunicorn))
$(eval $(call BuildPackage,python-gunicorn))
$(eval $(call BuildPackage,python-gunicorn-src))
$(eval $(call BuildPackage,gunicorn))

$(eval $(call Py3Package,python3-gunicorn))
$(eval $(call BuildPackage,python3-gunicorn))
$(eval $(call BuildPackage,python3-gunicorn-src))
$(eval $(call BuildPackage,gunicorn3))
