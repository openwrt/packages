#
# Copyright (C) 2008-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radicale
PKG_VERSION:=1.1.6
PKG_RELEASE:=1
PKG_MAINTAINER:=Christian Schoenebeck <christian.schoenebeck@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/Kozea/Radicale
PKG_SOURCE_VERSION:=7568ec39f09a753217fb2d525c5f8db64f4d98f4
PKG_MIRROR_HASH:=73de51e296479f860d4d8cd383a6aa34e8c702d9fca63b0499c7fcc2e794e6df
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_SUBDIR=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-package.mk
include ../../lang/python/python3-package.mk

# no default dependencies
PKG_DEFAULT_DEPENDS:=

define Package/radicale/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=http://radicale.org/
  TITLE:=Radicale CalDAV/CardDAV server
  PKGARCH:=all
  USERID:=radicale=5232:radicale=5232
endef
define Package/radicale-py2
  $(call Package/radicale/Default)
  TITLE+= (Python 2)
  VARIANT:=2
  DEPENDS:=+python-logging +python-openssl +python-xml +python-codecs
endef
define Package/radicale-py3
  $(call Package/radicale/Default)
  TITLE+= (Python 3)
  VARIANT:=3
  DEPENDS:=+python3-logging +python3-openssl +python3-xml +python3-codecs +python3-email
endef

# shown in LuCI package description
define Package/radicale-py2/description
Radicale CalDAV/CardDAV server (Python 2) - Homepage: http://radicale.org/
endef
define Package/radicale-py3/description
Radicale CalDAV/CardDAV server (Python 3) - Homepage: http://radicale.org/
endef

# shown in make menuconfig <Help>
define Package/radicale-py2/config
    help
	The Radicale Project is a CalDAV (calendar) and CardDAV (contact) server.
	It aims to be a light solution, easy to use, easy to install, easy to configure.
	As a consequence, it requires few software dependances and is pre-configured to work out-of-the-box.
	!!! Will install and use Python $(VARIANT) !!!
	.
	Version : $(PKG_VERSION)
	Homepage: http://radicale.org/
endef
Package/radicale-py3/config = $(Package/radicale-py2/config)

define Package/radicale-py2/conffiles
/etc/config/radicale
/etc/radicale/users
/etc/radicale/rights
endef
Package/radicale-py3/conffiles = $(Package/radicale-py2/conffiles)

define Build/Configure
	# nothing to configure
endef
define Build/Compile
	# nothing to compile
endef

define Package/radicale-py2/preinst
	#!/bin/sh
	[ -n "$${IPKG_INSTROOT}" ] && exit 0	# if run within buildroot exit

	# stop service if PKG_UPGRADE
	[ "$${PKG_UPGRADE}" = "1" ] && /etc/init.d/radicale stop >/dev/null 2>&1

	exit 0	# suppress errors from stop command
endef
define Package/radicale-py3/preinst
$(call Package/radicale-py2/preinst)
endef

define Package/radicale/inst_all
	$(INSTALL_DIR)	$(1)/etc/init.d
	$(INSTALL_BIN)  ./files/radicale.init    $(1)/etc/init.d/radicale

	$(INSTALL_DIR)	$(1)/etc/hotplug.d/iface
	$(INSTALL_BIN)  ./files/radicale.hotplug $(1)/etc/hotplug.d/iface/80-radicale

	$(INSTALL_DIR)	$(1)/etc/config
	$(INSTALL_CONF) ./files/radicale.config  $(1)/etc/config/radicale

	$(INSTALL_DIR)	$(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/radicale.upgrade $(1)/lib/upgrade/keep.d/radicale

	$(INSTALL_DIR)	$(1)/etc/radicale/ssl
	$(INSTALL_DATA) ./files/config.template  $(1)/etc/radicale/config.template
	$(INSTALL_DATA) ./files/logging.template $(1)/etc/radicale/logging.template
	$(INSTALL_DATA) ./files/radicale.users   $(1)/etc/radicale/users
	$(INSTALL_DATA) ./files/radicale.rights  $(1)/etc/radicale/rights

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/radicale $(1)/usr/bin/
endef
define Package/radicale-py2/install
	$(call Package/radicale/inst_all, $(1))
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)/radicale
	$(CP) $(PKG_BUILD_DIR)/radicale/* $(1)$(PYTHON_PKG_DIR)/radicale
endef
define Package/radicale-py3/install
	$(call Package/radicale/inst_all, $(1))
	$(INSTALL_DIR) $(1)$(PYTHON3_PKG_DIR)/radicale
	$(CP) $(PKG_BUILD_DIR)/radicale/* $(1)$(PYTHON3_PKG_DIR)/radicale
endef

define Package/radicale-py2/postinst
	#!/bin/sh
	# patch /usr/bin/radicale force run using python2
	/bin/sed -i 's/python/python2/' $${IPKG_INSTROOT}/usr/bin/radicale
endef
define Package/radicale-py3/postinst
	#!/bin/sh
	# patch /usr/bin/radicale force run using python3
	/bin/sed -i 's/python/python3/' $${IPKG_INSTROOT}/usr/bin/radicale
endef

$(eval $(call BuildPackage,radicale-py2))
$(eval $(call BuildPackage,radicale-py3))
