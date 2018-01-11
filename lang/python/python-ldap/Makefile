#
# Copyright (C) 2016-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-ldap
PKG_VERSION:=2.4.32
PKG_RELEASE:=1
PKG_MAINTAINER:=Dmitry Trefilov <the-alien@live.ru>
PKG_LICENSE:=Python-style
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/67/d9/fa0ea70d1792875745116ad62ac8d4bcb07550b15cded591bb57df6a6d9a
PKG_HASH:=5810f1b5a9ae9255df99fb9c2dcab7352fed325687efda56c0faae1a82c5e3cb

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-ldap
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  DEPENDS:=+libopenldap +python
  TITLE:=Python modules for implementing LDAP clients
  URL:=http://python-ldap.org/
endef

define Package/python-ldap/description
  python-ldap provides an object-oriented API to access LDAP directory
  servers from Python programs. Mainly it wraps the OpenLDAP 2.x libs
  for that purpose. Additionally the package contains modules for
  other LDAP-related stuff (e.g. processing LDIF, LDAPURLs, LDAPv3
  schema, LDAPv3 extended operations and controls, etc.).
endef

define Build/Compile
	$(call Build/Compile/PyMod,,build_ext \
		--include-dirs="$(STAGING_DIR)/usr/include:$(STAGING_DIR)/usr/include/sasl" \
		--library-dirs="$(STAGING_DIR)/usr/lib:$(STAGING_DIR)/usr/lib/sasl2" \
	build_py \
	install --prefix="$(PKG_INSTALL_DIR)/usr")
endef

define PyPackage/python-ldap/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call PyPackage,python-ldap))
$(eval $(call BuildPackage,python-ldap))
