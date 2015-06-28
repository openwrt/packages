#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radicale
PKG_VERSION:=0.10
PKG_RELEASE:=2
PKG_MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=Radicale-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://pypi.python.org/packages/source/R/Radicale/
PKG_MD5SUM:=32655d8893962956ead0ad690cca6044

# needed for "r"adicale <-> "R"adicale
PKG_BUILD_DIR:=$(BUILD_DIR)/Radicale-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

# no default dependencies
PKG_DEFAULT_DEPENDS=

define Package/$(PKG_NAME)/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=http://radicale.org/
  PKGARCH:=all
  USERID:=radicale=5232:radicale=5232
endef
define Package/$(PKG_NAME)-py2
  $(call Package/$(PKG_NAME)/Default)
  PYTHON_VERSION:=2.7
  TITLE:=Radicale CalDAV/CardDAV server (Python 2)
  VARIANT:=python2
  DEPENDS:=+python-logging +python-openssl +python-xml +python-codecs
endef
define Package/$(PKG_NAME)-py3
  $(call Package/$(PKG_NAME)/Default)
  PYTHON_VERSION:=3.4
  TITLE:=Radicale CalDAV/CardDAV server (Python 3)
  VARIANT:=python3
  DEPENDS:=+python3-logging +python3-openssl +python3-xml +python3-codecs +python3-email @BROKEN
endef

# shown in LuCI package description
define Package/$(PKG_NAME)-py2/description
Radicale CalDAV/CardDAV server (Python 2) - Homepage: http://radicale.org/
endef
define Package/$(PKG_NAME)-py3/description
Radicale CalDAV/CardDAV server (Python 3) - Homepage: http://radicale.org/
endef

# shown in make menuconfig <Help>
define Package/$(PKG_NAME)-py2/config
    help
	The Radicale Project is a CalDAV (calendar) and CardDAV (contact) server.
	It aims to be a light solution, easy to use, easy to install, easy to configure.
	As a consequence, it requires few software dependances and is pre-configured to work out-of-the-box.
	!!! Will install and use Python $(PYTHON_VERSION) !!!
	.
	Version : $(PKG_VERSION)
	Homepage: http://radicale.org/
	.
	$(PKG_MAINTAINER)
endef
Package/$(PKG_NAME)-py3/config = $(Package/$(PKG_NAME)-py2/config)

define Package/$(PKG_NAME)-py2/conffiles
/etc/config/radicale
/etc/radicale/users
/etc/radicale/rights
endef
Package/$(PKG_NAME)-py3/conffiles = $(Package/$(PKG_NAME)-py2/conffiles)

define Build/Configure
endef
define Build/Compile
endef

define Package/$(PKG_NAME)-py2/preinst
	#!/bin/sh
	[ -n "$${IPKG_INSTROOT}" ] && exit 0	# if run within buildroot exit

	# stop service if PKG_UPGRADE
	[ "$${PKG_UPGRADE}" = "1" ] && /etc/init.d/$(PKG_NAME) stop >/dev/null 2>&1

	exit 0	# supress errors from stop command
endef
define Package/$(PKG_NAME)-py3/preinst
$(call Package/$(PKG_NAME)-py2/preinst)
endef

define Package/$(PKG_NAME)-py2/install
	$(INSTALL_DIR)  $(1)/etc/init.d
	$(INSTALL_BIN)  ./files/radicale.init $(1)/etc/init.d/radicale
	$(INSTALL_DIR)  $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN)  ./files/radicale.hotplug $(1)/etc/hotplug.d/iface/80-radicale
	$(INSTALL_DIR)  $(1)/etc/config
	$(INSTALL_CONF) ./files/radicale.config $(1)/etc/config/radicale

	$(INSTALL_DIR)  $(1)/etc/radicale/ssl
	$(INSTALL_DATA) ./files/config.template  $(1)/etc/radicale/
	$(INSTALL_DATA) ./files/logging.template $(1)/etc/radicale/
	$(INSTALL_DATA) ./files/radicale.users   $(1)/etc/radicale/users
	$(INSTALL_DATA) ./files/radicale.rights  $(1)/etc/radicale/rights

	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/radicale
	$(CP) \
		$(PKG_BUILD_DIR)/radicale/* \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/radicale

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/radicale $(1)/usr/bin/
endef
define Package/$(PKG_NAME)-py3/install
	$(call Package/$(PKG_NAME)-py2/install, $(1))
endef

define Package/$(PKG_NAME)-py2/postinst
	#!/bin/sh
	# patch /usr/bin/radicale force run using python2
	/bin/sed -i 's/python/python2/' $${IPKG_INSTROOT}/usr/bin/radicale
endef
define Package/$(PKG_NAME)-py3/postinst
	#!/bin/sh
	# patch /usr/bin/radicale force run using python3
	/bin/sed -i 's/python/python3/' $${IPKG_INSTROOT}/usr/bin/radicale
endef

$(eval $(call BuildPackage,$(PKG_NAME)-py2))
$(eval $(call BuildPackage,$(PKG_NAME)-py3))
