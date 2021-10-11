#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-oauthlib
PKG_VERSION:=3.1.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PYPI_NAME:=oauthlib
PKG_HASH:=8f0215fcc533dd8dd1bee6f4c412d4f0cd7297307d43ac61666389e3bc3198a3

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-oauthlib
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=OAuth request-signing logic for Python
  URL:=https://github.com/oauthlib/oauthlib
  DEPENDS:=+python3-light
endef

define Package/python3-oauthlib/description
  A generic, spec-compliant, thorough implementation of the OAuth request-signing
  logic for Python
endef

$(eval $(call Py3Package,python3-oauthlib))
$(eval $(call BuildPackage,python3-oauthlib))
$(eval $(call BuildPackage,python3-oauthlib-src))
