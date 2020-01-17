#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-certifi
PKG_VERSION:=2019.11.28
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

PYPI_NAME:=certifi
PKG_HASH:=25b64c7da4cd7479594d035c08c2d809eb4aab3a26e5a990ea98cc450c320f1f

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

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
