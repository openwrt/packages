#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests-oauthlib
PKG_VERSION:=1.2.0
PKG_RELEASE:=2

PKG_MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=requests-oauthlib-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/requests-oauthlib
PKG_HASH:=bd6533330e8748e94bf0b214775fed487d309b8b8fe823dc45641ebcd9a32f57

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-requests-oauthlib-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-requests-oauthlib/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=OAuthlib auth for Requests
  URL:=https://github.com/requests/requests-oauthlib
endef

define Package/python-requests-oauthlib
  $(call Package/python-requests-oauthlib/Default)
  DEPENDS:= \
	+PACKAGE_python-requests-oauthlib:python \
	+PACKAGE_python-requests-oauthlib:python-oauthlib \
	+PACKAGE_python-requests-oauthlib:python-requests
  VARIANT:=python
endef

define Package/python3-requests-oauthlib
  $(call Package/python-requests-oauthlib/Default)
  DEPENDS:= \
	+PACKAGE_python3-requests-oauthlib:python3 \
	+PACKAGE_python3-requests-oauthlib:python3-oauthlib \
	+PACKAGE_python3-requests-oauthlib:python3-requests
  VARIANT:=python3
endef

define Package/python-requests-oauthlib/description
  This python package provides first-class OAuth library support
  for Requests.
endef

define Package/python3-requests-oauthlib/description
$(call Package/python-requests-oauthlib/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-requests-oauthlib))
$(eval $(call BuildPackage,python-requests-oauthlib))
$(eval $(call BuildPackage,python-requests-oauthlib-src))

$(eval $(call Py3Package,python3-requests-oauthlib))
$(eval $(call BuildPackage,python3-requests-oauthlib))
$(eval $(call BuildPackage,python3-requests-oauthlib-src))
