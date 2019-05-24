#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-elasticsearch
PKG_VERSION:=7.0.1
PKG_RELEASE:=1

PKG_SOURCE:=elasticsearch-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/9c/b2/943754369c90a394da7ab890bb9e88caa32c419719fefaba0f96b7e27c84/
PKG_HASH:=445c6ea9c55c493bae635718de6b276034f55378c836f9550ae49dd8cd04a02b

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-elasticsearch-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-elasticsearch/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://elasticsearch-py.rtfd.org
endef

define Package/python-elasticsearch
$(call Package/python-elasticsearch/Default)
  TITLE:=python-elasticsearch
  DEPENDS:=+PACKAGE_python-elasticsearch:python-light
  VARIANT:=python
endef

define Package/python3-elasticsearch
$(call Package/python-elasticsearch/Default)
  TITLE:=python3-elasticsearch
  DEPENDS:=+PACKAGE_python3-elasticsearch:python3-light
  VARIANT:=python3
endef

define Package/python-elasticsearch/description
Official low-level client for Elasticsearch. Its goal is to provide common
ground for all Elasticsearch-related code in Python; because of this it tries to
be opinion-free and very extendable.
endef

define Package/python3-elasticsearch/description
$(call Package/python-elasticsearch/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-elasticsearch))
$(eval $(call BuildPackage,python-elasticsearch))
$(eval $(call BuildPackage,python-elasticsearch-src))

$(eval $(call Py3Package,python3-elasticsearch))
$(eval $(call BuildPackage,python3-elasticsearch))
$(eval $(call BuildPackage,python3-elasticsearch-src))
