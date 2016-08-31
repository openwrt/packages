#
# Copyright (C) 2007-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-urllib3
PKG_VERSION:=1.16
PKG_RELEASE:=1
PKG_LICENSE:=MIT

PKG_SOURCE:=urllib3-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/urllib3-$(PKG_VERSION)/
PKG_SOURCE_URL:=https://pypi.python.org/packages/3b/f0/e763169124e3f5db0926bc3dbfcd580a105f9ca44cf5d8e6c7a803c9f6b5/
PKG_MD5SUM:=fcaab1c5385c57deeb7053d3d7d81d59
PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

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
