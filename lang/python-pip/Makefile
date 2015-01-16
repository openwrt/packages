#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pip
PKG_VERSION:=1.5.6
PKG_RELEASE:=1

PKG_SOURCE:=pip-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://pypi.python.org/packages/source/p/pip/
PKG_MD5SUM:=01026f87978932060cc86c1dc527903e

PKG_BUILD_DIR:=$(BUILD_DIR)/pip-$(PKG_VERSION)
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pip
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Tool for installing Python packages.
  URL:=https://pip.pypa.io
  DEPENDS:=+python +python-setuptools
endef

define Package/python-pip/description
  A tool for installing and managing Python packages.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix="$(PKG_INSTALL_DIR)/usr" \
	)
endef

PYTHON_PIP_PKG_DIR:=$(PYTHON_PKG_DIR)/pip-$(PKG_VERSION)-py$(PYTHON_VERSION).egg/pip
define PyPackage/python-pip/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PIP_PKG_DIR)/_vendor/distlib/*.exe
endef

# Backup these files, so that they do not clash with python-setuptools
# If we install python-pip python-setuptools, we want these to be replaced,
# since python-pip replaces python-setuptools (when installed)
define Package/python-pip/preinst
#!/bin/sh
cd "$${IPKG_INSTROOT}$(PYTHON_PKG_DIR)"
mv -f easy-install.pth easy-install.pth.old
mv -f site.py site.py.old
exit 0
endef

# And put them back on remove
define Package/python-pip/postrm
#!/bin/sh
cd "$${IPKG_INSTROOT}$(PYTHON_PKG_DIR)"
mv -f easy-install.pth.old easy-install.pth
mv -f site.py.old site.py
exit 0
endef

define PyPackage/python-pip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin
endef

$(eval $(call PyPackage,python-pip))
$(eval $(call BuildPackage,python-pip))

