#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-et_xmlfile
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>, Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=MIT

PKG_SOURCE:=et_xmlfile-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/e/et_xmlfile
PKG_HASH:=614d9722d572f6246302c4491846d2c393c199cfa4edc9af593437691683335b

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-et_xmlfile-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-et_xmlfile/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Low memory library for creating large XML files.
  URL:=https://bitbucket.org/openpyxl/et_xmlfile
endef

define Package/python-et_xmlfile
$(call Package/python-et_xmlfile/Default)
  DEPENDS:= \
	+PACKAGE_python-et_xmlfile:python-light \
	+PACKAGE_python-et_xmlfile:python-lxml
  VARIANT:=python
endef

define Package/python3-et_xmlfile
$(call Package/python-et_xmlfile/Default)
  DEPENDS:= \
	+python3-light \
	+python3-lxml
  VARIANT:=python3
endef

define Package/python-et_xmlfile/description
  An implementation of lxml.xmlfile for the standard library.
  It is based upon the xmlfile module from lxml with the aim of
  allowing code to be developed that will work with both libraries.
endef

define Package/python3-et_xmlfile/description
$(call Package/python-et_xmlfile/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-et_xmlfile))
$(eval $(call BuildPackage,python-et_xmlfile))
$(eval $(call BuildPackage,python-et_xmlfile-src))

$(eval $(call Py3Package,python3-et_xmlfile))
$(eval $(call BuildPackage,python3-et_xmlfile))
$(eval $(call BuildPackage,python3-et_xmlfile-src))
