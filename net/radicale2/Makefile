# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=radicale2
PKG_VERSION:=2.1.11
PKG_RELEASE:=1
PKG_MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:radicale:radicale

PKG_SOURCE:=Radicale-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/R/Radicale/
PKG_HASH:=02273fcc6ae10e0f74aa12652e24d0001eec8dbf467d54ddb4dfcc2af7d7a5db
PKG_BUILD_DIR:=$(BUILD_DIR)/radicale2-$(BUILD_VARIANT)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/radicale2/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=http://radicale.org/
  TITLE:=Radicale 2.x CalDAV/CardDAV server
  MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>
endef

define Package/radicale2
$(call Package/radicale2/Default)
  USERID:=radicale2=225:radicale2=225
  DEPENDS:=+python3 +python3-dateutil +python3-vobject +python3-setuptools
  CONFLICTS:=radicale
  VARIANT:=python3
endef

define Package/radicale2-examples
$(call Package/radicale2/Default)
  TITLE:=Radicale v2 example configs
endef

define Package/radicale2-meta/description
The Radicale Project is a CalDAV (calendar) and CardDAV (contact) server. It aims to be a light solution, easy to use, easy to install, easy to configure. As a consequence, it requires few software dependances and is pre-configured to work out-of-the-box.

The Radicale Project runs on most of the UNIX-like platforms (Linux, BSD, MacOS X) and Windows. It is known to work with Evolution, Lightning, iPhone and Android clients. It is free and open-source software, released under GPL version 3.
endef

define Package/radicale2/description
$(call Package/radicale2-meta/description)
.
This package contains the python files.
endef

define Package/radicale2-examples/description
$(call Package/radicale2-meta/description)
.
This package contains upstream configs for example purposes.
endef

define Package/radicale2/conffiles
/etc/config/radicale2
/etc/radicale2/config
/etc/radicale2/users
/etc/radicale2/rights
/etc/radicale2/logging
endef

define Package/radicale2/preinst
	#!/bin/sh
	[ -n "$${IPKG_INSTROOT}" ] && exit 0	# if run within buildroot exit

	# stop service if PKG_UPGRADE
	[ "$${PKG_UPGRADE}" = "1" ] && /etc/init.d/radicale2 stop >/dev/null 2>&1

	exit 0	# suppress errors from stop command
endef

define Py3Package/radicale2/filespec
  +|$(PYTHON3_PKG_DIR)
  +|/usr/bin/radicale2|0755
endef

define Py3Package/radicale2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/radicale $(PKG_INSTALL_DIR)/usr/bin/radicale2
	$(SED) 's,^#!.*python.*,#!/usr/bin/python$(PYTHON3_VERSION),' $(PKG_INSTALL_DIR)/usr/bin/radicale2
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) ./files/radicale2.config $(1)/etc/config/radicale2
	$(INSTALL_BIN) ./files/radicale2.init $(1)/etc/init.d/radicale2
endef

define Package/radicale2-examples/install
	$(INSTALL_DIR) $(1)/usr/share/radicale2
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/config $(1)/usr/share/radicale2/config.example
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/rights $(1)/usr/share/radicale2/rights.example
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/logging $(1)/usr/share/radicale2/logging.example
endef

$(eval $(call Py3Package,radicale2))
$(eval $(call BuildPackage,radicale2))
$(eval $(call BuildPackage,radicale2-src))
$(eval $(call BuildPackage,radicale2-examples))
