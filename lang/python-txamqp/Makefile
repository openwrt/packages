#
# Copyright (C) 2009-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=txAMQP
PKG_VERSION:=0.6.2
PKG_RELEASE:=1
PKG_MAINTAINER:=Nate <natester@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/63/96/13eabebc8c9970a320c2abd2458fdfe64dabfe60bf676200a183835aa3fa/
PKG_MD5SUM:=8c3e9c42d60d06b088d91ed9ba159e13

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-txamqp
	SECTION:=lang-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-txAMQP
	URL:=https://launchpad.net/txamqp
	DEPENDS:=+python +libgmp +twisted
endef

define Package/python-txamqp/description
Python library for communicating with AMQP peers and brokers using Twisted.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root=$(PKG_INSTALL_DIR),\
		CONFIG_BIG_ENDIAN="$(CONFIG_BIG_ENDIAN)" \
	)
endef

define Package/python-txamqp/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)/
	$(CP) \
		$(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
		$(1)$(PYTHON_PKG_DIR)/
endef

$(eval $(call PyPackage,python-txamqp))
$(eval $(call BuildPackage,python-txamqp))

