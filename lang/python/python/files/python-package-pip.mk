#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-pip
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) pip module
  VERSION:=$(PYTHON_PIP_VERSION)
  DEPENDS:=+python +python-setuptools +python-pip-conf
endef

define PyPackage/python-pip/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib/python$(PYTHON_VERSION)/site-packages
	# Adjust shebang to proper python location on target
	sed "1s@.*@#\!/usr/bin/python$(PYTHON_VERSION)@" -i $(PKG_BUILD_DIR)/install-pip/bin/*
	$(CP) $(PKG_BUILD_DIR)/install-pip/bin/* $(1)/usr/bin
	$(CP) \
		$(PKG_BUILD_DIR)/install-pip/lib/python$(PYTHON_VERSION)/site-packages/pip \
		$(1)/usr/lib/python$(PYTHON_VERSION)/site-packages/
endef

$(eval $(call PyBasePackage,python-pip, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
