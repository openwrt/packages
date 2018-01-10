#
# Copyright (C) 2007-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-urllib3
PKG_VERSION:=1.22
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=urllib3-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/urllib3-$(PKG_VERSION)/
PKG_SOURCE_URL:=https://pypi.python.org/packages/ee/11/7c59620aceedcc1ef65e156cc5ce5a24ef87be4107c2b74458464e437a5d/
PKG_HASH:=cc44da8e1145637334317feebd728bd869a35285b93cbb4cca2577da7e62db4f

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-urllib3
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  MAINTAINER:=Gergely Kiss <mail.gery@gmail.com>
  TITLE:=HTTP library with thread-safe connection pooling, file post, and more.
  URL:=https://urllib3.readthedocs.io/
  DEPENDS:=+python
endef

define Package/python-urllib3/description
  HTTP library with thread-safe connection pooling, file post, and more.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,install --prefix=/usr --root=$(PKG_INSTALL_DIR))
endef

define Package/python-urllib3/install
	$(INSTALL_DIR) $(1)$(PYTHON_PKG_DIR)
	$(CP) \
	    $(PKG_INSTALL_DIR)$(PYTHON_PKG_DIR)/* \
	    $(1)$(PYTHON_PKG_DIR)
endef

$(eval $(call BuildPackage,python-urllib3))
