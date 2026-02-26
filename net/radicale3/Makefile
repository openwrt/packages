# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

# cspell:words TOPDIR PYPI Radicale conffiles dateutil defusedxml libpass
# cspell:words setuptools vobject

include $(TOPDIR)/rules.mk

PKG_NAME:=radicale3
PKG_VERSION:=3.6.1
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING.md
PKG_CPE_ID:=cpe:/a:radicale:radicale

PYPI_NAME:=Radicale
PYPI_SOURCE_NAME:=radicale
PKG_HASH:=5b5529c093fc3a6e9eba6a3280d930ea6573b485a1bd8d25b7daa6ee70f5224b

PKG_MAINTAINER:=Daniel F. Dickinson <dfdpublic@wildtechgarden.ca>

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/radicale3
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://radicale.org/
  TITLE:=Radicale 3.x CalDAV/CardDAV server
  USERID:=radicale3=226:radicale3=226
  DEPENDS:=+python3 +python3-dateutil +python3-vobject +python3-setuptools \
    +python3-defusedxml +python3-libpass +python3-requests +python3-pika \
    +python3-packaging
  PROVIDES:=radicale radicale2
endef

define Package/radicale3/description
  The Radicale Project is a CalDAV (calendar) and CardDAV (contact) server.
  It aims to be a light solution, easy to use, easy to install, easy to
  configure. As a consequence, it requires few software dependencies and is
  pre-configured to work out-of-the-box.
  The Radicale Project runs on most of the UNIX-like platforms
  (Linux, BSD, MacOS X) and Windows. It is known to work with Evolution,
  Lightning, iPhone and Android clients. It is free and open-source software,
  released under GPL version 3.

  This package contains the python files.
endef

define Package/radicale3/conffiles
/etc/config/radicale3
endef

define Py3Package/radicale3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/radicale $(1)/usr/bin/radicale3
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/radicale3.config $(1)/etc/config/radicale3
	$(INSTALL_BIN) ./files/radicale3.init $(1)/etc/init.d/radicale3
endef

$(eval $(call Py3Package,radicale3))
$(eval $(call BuildPackage,radicale3))
$(eval $(call BuildPackage,radicale3-src))
