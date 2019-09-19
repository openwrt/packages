#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-certifi
PKG_VERSION:=2019.9.11
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=certifi-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/c/certifi
PKG_HASH:=e4f3620cfea4f83eedc95b24abd9cd56f3c4b146dd0177e83a21b4eb49e21e50

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-certifi-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-certifi/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python package for Mozilla's CA Bundle
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
