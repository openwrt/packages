#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-requests
PKG_VERSION:=2.21.0
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=requests-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/r/requests
PKG_HASH:=502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e
PKG_BUILD_DIR:=$(BUILD_DIR)/requests-$(PKG_VERSION)

PKG_CPE_ID:=cpe:/a:python-requests:requests

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-requests
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Eneas U de Queiroz <cote2004-github@yahoo.com>
  TITLE:=HTTP library for Python
  URL:=http://python-requests.org/
  DEPENDS:=+python +chardet +python-idna +python-urllib3 +python-certifi
  VARIANT:=python
endef

define Package/python-requests/description
  Requests is the only Non-GMO HTTP library for Python, safe for human consumption.
endef

$(eval $(call PyPackage,python-requests))
$(eval $(call BuildPackage,python-requests))
$(eval $(call BuildPackage,python-requests-src))
