#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-oauthlib
PKG_VERSION:=3.0.2
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=oauthlib-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/o/oauthlib
PKG_HASH:=b4d99ae8ccfb7d33ba9591b59355c64eef5241534aa3da2e4c0435346b84bc8e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-oauthlib-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-oauthlib/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=OAuth request-signing logic for Python
  URL:=https://github.com/oauthlib/oauthlib
endef

define Package/python-oauthlib
  $(call Package/python-oauthlib/Default)
  DEPENDS:=+PACKAGE_python-oauthlib:python-light
  VARIANT:=python
endef

define Package/python3-oauthlib
  $(call Package/python-oauthlib/Default)
  DEPENDS:=+PACKAGE_python3-oauthlib:python3-light
  VARIANT:=python3
endef

define Package/python-oauthlib/description
  A generic, spec-compliant, thorough implementation of the OAuth request-signing
  logic for Python
endef

define Package/python3-oauthlib/description
$(call Package/python-oauthlib/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-oauthlib))
$(eval $(call BuildPackage,python-oauthlib))
$(eval $(call BuildPackage,python-oauthlib-src))

$(eval $(call Py3Package,python3-oauthlib))
$(eval $(call BuildPackage,python3-oauthlib))
$(eval $(call BuildPackage,python3-oauthlib-src))
