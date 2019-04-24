#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-certifi
PKG_VERSION:=2019.3.9
PKG_RELEASE:=1
PKG_LICENSE:=MPL-2.0

PKG_SOURCE:=certifi-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/c/certifi
PKG_HASH:=b26104d6835d1f5e49452a26eb2ff87fe7090b89dfcaee5ea2212697e1e1d7ae
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-certifi-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

define Package/python-certifi/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=Python package for providing Mozilla's CA Bundle.
  URL:=http://certifi.io/
endef

define Package/python-certifi
  $(call Package/python-certifi/Default)
  DEPENDS:=+PACKAGE_python-certifi:python-light
  VARIANT:=python
endef

define Package/python3-certifi
  $(call Package/python-certifi/Default)
  DEPENDS:=+PACKAGE_python3-certifi:python3-light
  VARIANT:=python3
endef

define Package/python-certifi/description
  Certifi is a carefully curated collection of Root Certificates for validating the
  trustworthiness of SSL certificates while verifying the identity of TLS hosts.
endef

define Package/python3-certifi/description
$(call Package/python-certifi/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-certifi))
$(eval $(call BuildPackage,python-certifi))
$(eval $(call BuildPackage,python-certifi-src))

$(eval $(call Py3Package,python3-certifi))
$(eval $(call BuildPackage,python3-certifi))
$(eval $(call BuildPackage,python3-certifi-src))
